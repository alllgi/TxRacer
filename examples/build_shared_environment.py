import argparse
import copy
import hashlib
import json
from pathlib import Path
import subprocess


def build(compiler, output):
    output.mkdir(parents=True, exist_ok=False)
    source = Path(__file__).resolve().parent / "contracts/shared_environment.sol"
    result = subprocess.run([str(compiler), "--combined-json", "abi,bin", str(source)],
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True,
                            check=True, timeout=30)
    compiled = json.loads(result.stdout)["contracts"]
    user, attacker = "0x" + "11" * 20, "0x" + "22" * 20
    def write(name, value):
        raw = (json.dumps(value, indent=2, sort_keys=True) + "\n").encode()
        (output / name).write_bytes(raw)
        return hashlib.sha256(raw).hexdigest()
    module = dict(vm="petersburg", user=user, attacker=attacker,
        accounts=[dict(address=user, balance=10**21), dict(address=attacker, balance=10**21)],
        contracts=[], setup=[dict(contract="App", function="initialize(uint256)", arguments=[7], sender=user)],
        preparation=[], planner_candidates=[dict(contract="App", signature="touch(uint256)")],
        explorer={"seed": 17}, inference={}, scheduler={}, oracle={})
    for name, artifact, arguments in (("App", "SharedApplication", ["@Dependency"]), ("Dependency", "SharedDependency", [])):
        item = next(v for k, v in compiled.items() if k.endswith(":" + artifact))
        abi = json.loads(item["abi"]) if isinstance(item["abi"], str) else item["abi"]
        module["contracts"].append(dict(name=name, artifact=artifact, abi=abi, bytecode=item["bin"],
                                        constructor_arguments=arguments, sender=user))
    descriptors = []
    for name, value in (("left", 7), ("right", 9)):
        item = copy.deepcopy(module)
        item["setup"][0]["arguments"] = [value]
        filename = name + ".json"
        descriptors.append(dict(id=name, manifest=filename, sha256=write(filename, item)))
    recipe = dict(schema_version=1, name="two_instances", modules=descriptors,
        review_basis="Two local application instances share one source-backed dependency; no historical state is claimed.",
        bindings={"right.Dependency": "left.Dependency"},
        members=[dict(id="instance_0", instance="left.App", case_id="SharedApplication"),
                 dict(id="instance_1", instance="right.App", case_id="SharedApplication")],
        setup=[dict(id="connect", contract="left.App", function="connect(address)", arguments=["@right.App"], sender=user, after=["right.setup_0"])],
        integration_read_probes=[dict(contract="left.App", function="peer()", arguments=[], sender=user, expected=["@right.App"]),
            dict(contract="right.App", function="dependency()", arguments=[], sender=user, expected=["@left.Dependency"]),
            dict(contract="right.App", function="initialized()", arguments=[], sender=user, expected=[9])])
    write("recipe.json", recipe)
    write("build.json", dict(source=str(source), source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),
                             compiler=str(compiler), compiler_sha256=hashlib.sha256(compiler.read_bytes()).hexdigest()))
    print(output / "recipe.json")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--solc", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    build(args.solc.resolve(), args.output.resolve())
