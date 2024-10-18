import ExpoModulesCore

public class QrModule: Module {
    public func definition() -> ModuleDefinition {
        Name("QrModuleView")

        View(QrModuleView.self) {
            Events("onCodeScanned")
        }
    }
}
