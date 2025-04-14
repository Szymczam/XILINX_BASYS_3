# 2025-04-12T23:18:51.303650500
import vitis

client = vitis.create_client()
client.set_workspace(path="Vitis")

platform = client.get_component(name="platform")
status = platform.build()

status = platform.build()

comp = client.get_component(name="MicroblazeV")
comp.build()

domain = platform.get_domain(name="standalone_microblaze_riscv_0")

status = domain.regenerate()

status = platform.build()

comp.build()

