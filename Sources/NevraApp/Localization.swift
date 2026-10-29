import AppKit
import SwiftUI
import NevraCore

extension Notification.Name { static let nevraLanguageChanged=Notification.Name("NevraLanguageChanged") }
enum L10n {
    static var defaultLanguage:String {
        let pref = Locale.preferredLanguages.first ?? Locale.current.identifier
        return pref.lowercased().hasPrefix("tr") ? "tr" : "en"
    }
    static var language:String {
        if let saved = UserDefaults.standard.string(forKey:"appLanguage") {
            return AppLocalization.normalizedLanguage(saved)
        }
        return defaultLanguage
    }
    static func text(_ value:String)->String { AppLocalization.text(value,language:language) }
    static func uppercase(_ value:String)->String { AppLocalization.uppercased(text(value),language:language) }
    private static let menuSources=NSMapTable<NSMenuItem,NSString>.weakToStrongObjects()
    private static let windowSources=NSMapTable<NSWindow,NSString>.weakToStrongObjects()
    static func windowTitle(_ window:NSWindow,source:String) { windowSources.setObject(source as NSString,forKey:window);window.title=text(source) }
    static func updateWindowTitles() { for window in windowSources.keyEnumerator() { if let window=window as? NSWindow,let source=windowSources.object(forKey:window) { window.title=text(source as String) } } }
    static func menuTitle(_ item:NSMenuItem,source:String) { menuSources.setObject(source as NSString,forKey:item);item.title=text(source) }
    static func localize(_ menu:NSMenu?) {
        guard let menu else { return }
        for item in menu.items {
            let source=menuSources.object(forKey:item).map(String.init) ?? item.title
            menuTitle(item,source:source);localize(item.submenu)
        }
    }
}

/// Locale updates translate SwiftUI control labels without recreating editors or their drafts.
private struct LocalizedRoot<Content:View>:View {
    let content:Content
    @AppStorage("appLanguage") private var language=L10n.defaultLanguage
    var body:some View { content.environment(\.locale,Locale(identifier:AppLocalization.normalizedLanguage(language))) }
}
extension View { func nevraLanguage()->some View { LocalizedRoot(content:self) } }

/// Dynamic UI copy only; file names and document/user content remain verbatim.
struct LText:View {
    let source:String
    @AppStorage("appLanguage") private var language=L10n.defaultLanguage
    init(_ source:String) { self.source=source }
    var body:some View { Text(verbatim:AppLocalization.text(source,language:language)) }
}
