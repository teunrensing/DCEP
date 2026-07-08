Import("env")

import os
import shutil

ccache = shutil.which("ccache")

if ccache and os.environ.get("PLATFORMIO_DISABLE_CCACHE") != "1":
    for key in ("CC", "CXX"):
        if key in env:
            env.Replace(**{key: f"{ccache} {env[key]}"})

