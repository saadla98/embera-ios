// Sample-only excerpt for public presentation. Not the full app code.

import SwiftUI

struct EmberaProduct: Identifiable, Hashable {
    let id: UUID
    let name: String
    let origin: String
    let roast: String
    let tastingNotes: [String]
    let price: Decimal
}

struct EmberaTheme {
    static let background = Color(hex: 0x0B0908)
    static let surface = Color(hex: 0x1F1A17)
    static let glass = Color(hex: 0x2B2522, alpha: 0.55)
    static let highlight = Color(hex: 0xFF6A3D)
    static let textPrimary = Color(hex: 0xF6EFE8)
    static let textSecondary = Color(hex: 0xD5CBBF)
}

struct EmberaSpacing {
    static let xxs: CGFloat = 6
    static let xs: CGFloat = 10
    static let sm: CGFloat = 14
    static let md: CGFloat = 18
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 44
}

@MainActor
final class EmberaSampleViewModel: ObservableObject {
    @Published var featured: [EmberaProduct] = []
    @Published var isLoading = false
    @Published var selected: EmberaProduct?

    private let service: EmberaProductService

    init(service: EmberaProductService = EmberaMockProductService()) {
        self.service = service
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            featured = try await service.loadFeatured()
            selected = featured.first
        } catch {
            featured = []
        }
    }
}

protocol EmberaProductService {
    func loadFeatured() async throws -> [EmberaProduct]
}

struct EmberaMockProductService: EmberaProductService {
    func loadFeatured() async throws -> [EmberaProduct] {
        return [
            EmberaProduct(
                id: UUID(),
                name: "EMBERA Solstice",
                origin: "Ethiopia",
                roast: "Light",
                tastingNotes: ["Bergamot", "Honey", "Citrus"],
                price: 22
            ),
            EmberaProduct(
                id: UUID(),
                name: "EMBERA Aurora",
                origin: "Colombia",
                roast: "Medium",
                tastingNotes: ["Cacao", "Orange", "Almond"],
                price: 20
            ),
            EmberaProduct(
                id: UUID(),
                name: "EMBERA Nocturne",
                origin: "Guatemala",
                roast: "Dark",
                tastingNotes: ["Toffee", "Smoke", "Plum"],
                price: 21
            )
        ]
    }
}

struct EmberaSampleView: View {
    @StateObject private var viewModel = EmberaSampleViewModel()

    var body: some View {
        ZStack {
            EmberaTheme.background
                .ignoresSafeArea()
            VStack(alignment: .leading, spacing: EmberaSpacing.lg) {
                header
                if viewModel.isLoading {
                    ProgressView()
                        .tint(EmberaTheme.highlight)
                } else {
                    featuredCarousel
                }
            }
            .padding(EmberaSpacing.xl)
        }
        .task { await viewModel.load() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: EmberaSpacing.sm) {
            Text("EMBERA")
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .foregroundStyle(EmberaTheme.textPrimary)
            Text("Cinematic coffee ritual")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(EmberaTheme.textSecondary)
        }
    }

    private var featuredCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: EmberaSpacing.md) {
                ForEach(viewModel.featured) { product in
                    EmberaProductCard(product: product, isSelected: product.id == viewModel.selected?.id)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.55, dampingFraction: 0.86)) {
                                viewModel.selected = product
                            }
                        }
                }
            }
        }
    }
}

struct EmberaProductCard: View {
    let product: EmberaProduct
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: EmberaSpacing.sm) {
            Text(product.name)
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(EmberaTheme.textPrimary)
            Text("\(product.origin) • \(product.roast) roast")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(EmberaTheme.textSecondary)
            HStack {
                ForEach(product.tastingNotes, id: \.self) { note in
                    Text(note)
                        .font(.system(size: 11, weight: .medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(EmberaTheme.surface)
                        .cornerRadius(999)
                        .overlay(RoundedRectangle(cornerRadius: 999).stroke(EmberaTheme.highlight.opacity(0.2)))
                }
            }
            Text("$\(product.price as NSDecimalNumber)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(EmberaTheme.highlight)
        }
        .padding(EmberaSpacing.md)
        .frame(width: 240, height: 180)
        .background(EmberaTheme.glass)
        .cornerRadius(24)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(EmberaTheme.highlight.opacity(isSelected ? 0.4 : 0.15)))
        .shadow(color: Color.black.opacity(0.35), radius: 20, x: 0, y: 10)
        .scaleEffect(isSelected ? 1.03 : 0.98)
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

#Preview {
    EmberaSampleView()
}
