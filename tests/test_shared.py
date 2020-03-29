# Just a common class to define root folder
import sys

from test_helper import Path, TestUtils

# Hack to let pytest find the helpers
ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(ROOT / "helpers"))


class TestHelpers(TestUtils):
    def get_root_folder(self) -> Path:
        return ROOT

    @property
    def run_folder(self) -> Path:
        return self.test_folder / ("out." + str(self.run_id))

    def update_run_id(self):
        if not hasattr(self, "run_id"):
            self.run_id = 1
        else:
            self.run_id += 1

    @property
    def project(self) -> str:
        return Path(__file__).parent.as_posix()

    @property
    def resources_folder(self) -> Path:
        return Path(__file__).parent / "resources"
