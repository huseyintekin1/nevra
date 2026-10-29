import AppKit
import SwiftUI

// One shared visual language, with native light/dark appearance and motion preferences.
enum NevraPalette {
    static func adaptive(_ light:(Double,Double,Double),_ dark:(Double,Double,Double))->NSColor {
        NSColor(name:nil) { appearance in
            let rgb=appearance.bestMatch(from:[.darkAqua,.aqua]) == .darkAqua ? dark:light
            return NSColor(srgbRed:rgb.0,green:rgb.1,blue:rgb.2,alpha:1)
        }
    }
    // Recommendation B: Deep slate & Clean modern porcelain
    static let canvas=Color(nsColor:adaptive((0.98,0.985,0.99),(0.07,0.09,0.11)))
    static let surface=Color(nsColor:adaptive((1.0,1.0,1.0),(0.11,0.14,0.17)))
    static let inset=Color(nsColor:adaptive((0.95,0.96,0.97),(0.09,0.11,0.13)))
    
    // Emerald & Mint accents
    static let emerald=Color(red:0.06,green:0.73,blue:0.51)
    static let cyan=Color(red:0.08,green:0.82,blue:0.76)
    static let forest=Color(nsColor:adaptive((0.05,0.45,0.33),(0.42,0.88,0.72)))
    static let sand=Color(nsColor:adaptive((0.93,0.94,0.96),(0.16,0.20,0.24)))
    static let sage=Color(nsColor:adaptive((0.88,0.96,0.92),(0.10,0.24,0.19)))
    static let border=Color.primary.opacity(0.08)
    static let gold=NevraArtwork.emerald
    static let ink=NevraArtwork.ink
    static let goldInk=Color(nsColor:adaptive((0.04,0.40,0.28),(0.42,0.92,0.73)))
    static let buttonInk=Color.white
    static let goldEnd=Color(red:0.08,green:0.82,blue:0.76)
}
extension Color { static let nevra=Color(nsColor:NevraPalette.gold) }

enum NevraMotion {
    static var enabled:Bool { !UserDefaults.standard.bool(forKey:"reduceAnimations") && !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion }
}
enum NevraAppearance {
    @MainActor static func apply(_ choice:String?=nil) {
        let choice=choice ?? UserDefaults.standard.string(forKey:"appAppearance") ?? "system"
        NSApp.appearance=choice=="light" ? NSAppearance(named:.aqua):choice=="dark" ? NSAppearance(named:.darkAqua):nil
    }
}

struct NevraMotionModifier<Value:Equatable>:ViewModifier {
    let value:Value
    @Environment(\.accessibilityReduceMotion) private var systemReduced
    @AppStorage("reduceAnimations") private var reduced=false
    func body(content:Content)->some View { content.animation(systemReduced || reduced ? nil:.spring(response:0.32,dampingFraction:0.88),value:value) }
}
struct NevraEntrance:ViewModifier {
    var delay=0.0
    @State private var visible=false
    @Environment(\.accessibilityReduceMotion) private var systemReduced
    @AppStorage("reduceAnimations") private var reduced=false
    func body(content:Content)->some View {
        content.opacity(visible ? 1:0).offset(y:visible || systemReduced || reduced ? 0:8)
            .onAppear {
                if systemReduced || reduced { visible=true }
                else { withAnimation(.easeOut(duration:0.24).delay(delay)) { visible=true } }
            }
    }
}
extension View {
    func nevraAnimation<V:Equatable>(value:V)->some View { modifier(NevraMotionModifier(value:value)) }
    func nevraEntrance(delay:Double=0)->some View { modifier(NevraEntrance(delay:delay)) }
    func nevraCard(radius:CGFloat=22)->some View {
        background(NevraPalette.surface,in:RoundedRectangle(cornerRadius:radius,style:.continuous))
            .overlay(RoundedRectangle(cornerRadius:radius,style:.continuous).strokeBorder(NevraPalette.border,lineWidth:1))
    }
}

enum NevraButtonKind { case primary,secondary,quiet }
struct NevraButtonStyle:ButtonStyle {
    var kind:NevraButtonKind = .secondary
    var compact=false
    init(_ kind:NevraButtonKind = .secondary,compact:Bool=false) { self.kind=kind;self.compact=compact }
    func makeBody(configuration:Configuration)->some View { NevraButtonBody(configuration:configuration,kind:kind,compact:compact) }
}
private struct NevraButtonBody:View {
    let configuration:ButtonStyleConfiguration
    let kind:NevraButtonKind
    let compact:Bool
    @State private var hovered=false
    @Environment(\.isEnabled) private var enabled
    @Environment(\.isFocused) private var focused
    @Environment(\.accessibilityReduceMotion) private var systemReduced
    @AppStorage("reduceAnimations") private var reduced=false
    private var primary:Bool { kind == .primary }
    var body:some View {
        configuration.label.font(.system(size:compact ? 11:13,weight:.semibold,design:.rounded))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal:false,vertical:true)
            .frame(minHeight:compact ? 14:18,alignment:.center)
            .padding(.horizontal,compact ? 10:15).padding(.vertical,compact ? 7:11)
            .foregroundStyle(primary ? NevraPalette.buttonInk:Color.primary)
            .background {
                RoundedRectangle(cornerRadius:compact ? 10:13,style:.continuous)
                    .fill(primary ? AnyShapeStyle(LinearGradient(colors:[Color.nevra,NevraPalette.goldEnd],startPoint:.leading,endPoint:.trailing)):AnyShapeStyle(kind == .quiet ? Color.clear:NevraPalette.surface))
                    .overlay(RoundedRectangle(cornerRadius:compact ? 10:13,style:.continuous).strokeBorder(primary ? Color.white.opacity(0.12):NevraPalette.border,lineWidth:kind == .quiet ? 0:1))
            }
            .overlay(RoundedRectangle(cornerRadius:compact ? 10:13).fill(Color.primary.opacity(hovered && !primary ? 0.035:0)))
            .overlay(RoundedRectangle(cornerRadius:compact ? 10:13).strokeBorder(focused ? NevraPalette.goldInk:Color.clear,lineWidth:2).padding(-3))
            .shadow(color:primary && enabled ? Color.nevra.opacity(hovered ? 0.20:0.10):.clear,radius:hovered ? 9:5,y:3)
            .scaleEffect(systemReduced || reduced ? 1:configuration.isPressed ? 0.97:hovered && enabled ? 1.015:1)
            .opacity(enabled ? 1:0.4).contentShape(RoundedRectangle(cornerRadius:13))
            .onHover { hovered=$0 }
            .animation(systemReduced || reduced ? nil:.easeOut(duration:0.14),value:configuration.isPressed)
            .animation(systemReduced || reduced ? nil:.easeOut(duration:0.16),value:hovered)
    }
}
struct NevraGroupBoxStyle:GroupBoxStyle {
    func makeBody(configuration:Configuration)->some View {
        VStack(alignment:.leading,spacing:16) {
            configuration.label.font(.system(size:13,weight:.semibold,design:.rounded)).foregroundStyle(NevraPalette.forest)
            configuration.content
        }.padding(20).frame(maxWidth:.infinity,alignment:.leading).nevraCard()
    }
}

struct NevraMark:View {
    var size:CGFloat=44
    var happy=false
    var body:some View {
        Image(nsImage:NevraArtwork.mark(size:size*2,happy:happy)).resizable().interpolation(.high).frame(width:size,height:size).accessibilityHidden(true)
    }
}

struct NevraPill:View {
    let title:String
    var symbol:String?=nil
    var color:Color=NevraPalette.forest
    var body:some View {
        HStack(spacing:5) { if let symbol { Image(systemName:symbol) };LText(title) }
            .font(.system(size:10,weight:.semibold,design:.rounded)).foregroundStyle(color == .nevra ? NevraPalette.goldInk:color)
            .padding(.horizontal,9).padding(.vertical,5).background(color.opacity(0.09),in:Capsule())
    }
}
struct NevraPageHeading:View {
    let eyebrow:String
    let title:String
    let subtitle:String
    var body:some View {
        VStack(alignment:.leading,spacing:8) {
            LText(eyebrow.uppercased()).font(.system(size:10,weight:.bold,design:.rounded)).tracking(1.4).foregroundStyle(NevraPalette.goldInk)
            LText(title).font(.system(size:27,weight:.bold,design:.rounded)).tracking(-0.7)
            LText(subtitle).font(.system(size:12)).foregroundStyle(.secondary).fixedSize(horizontal:false,vertical:true)
        }
    }
}
struct NevraCheck:View {
    @State private var arrived=false
    var body:some View {
        Image(systemName:"checkmark").font(.system(size:14,weight:.bold)).foregroundStyle(NevraPalette.forest)
            .frame(width:34,height:34).background(NevraPalette.sage,in:Circle())
            .scaleEffect(arrived ? 1:0.75).opacity(arrived ? 1:0)
            .nevraAnimation(value:arrived).onAppear{arrived=true}.accessibilityHidden(true)
    }
}
