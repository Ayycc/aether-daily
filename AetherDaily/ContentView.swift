import SwiftUI

// MARK: - Data Model
struct Article: Identifiable {
    let id = UUID()
    let headline: String
    let subheadline: String
    let summary: String
    let author: String
    let handle: String
    let timestamp: String
    let likes: Int
    let xURL: String
    let category: String
    let isHero: Bool
}

// MARK: - Sample Data (Seeded from real X posts - June 2026)
let sampleArticles: [Article] = [
    Article(
        headline: "OpenAI Unveils GPT-5.6 Family: Sol, Terra & Luna",
        subheadline: "Limited preview released amid regulatory discussions",
        summary: "OpenAI announced a limited preview of GPT-5.6 Sol (frontier), GPT-5.6 Terra (balanced), and GPT-5.6 Luna (fast & affordable). Sam Altman noted the rollout was scaled back at the request of the US government.",
        author: "OpenAI",
        handle: "@OpenAI",
        timestamp: "2h ago",
        likes: 45200,
        xURL: "https://x.com/OpenAI/status/2070555272230384038",
        category: "Models",
        isHero: true
    ),
    Article(
        headline: "Claude Joins Slack as a Full Team Member",
        subheadline: "New 'Claude Tag' feature lets teams delegate tasks directly",
        summary: "Anthropic's Claude can now be added to Slack workspaces with access to specific channels and tools, allowing users to @tag Claude for real work across projects.",
        author: "Claude",
        handle: "@claudeai",
        timestamp: "5h ago",
        likes: 28100,
        xURL: "https://x.com/claudeai/status/2069468693017268244",
        category: "Tools",
        isHero: false
    ),
    Article(
        headline: "Alibaba's Qwen Launches AgentWorld Language Model",
        subheadline: "A new 'language world model' that simulates entire environments",
        summary: "Qwen-AgentWorld can natively simulate search, terminal, web, OS, and Android environments. The team argues this is key to training models that truly understand and model the world rather than just act in it.",
        author: "Alibaba Qwen",
        handle: "@Alibaba_Qwen",
        timestamp: "8h ago",
        likes: 12400,
        xURL: "https://x.com/Alibaba_Qwen/status/2069720365442719867",
        category: "Research",
        isHero: false
    ),
    Article(
        headline: "Nous Research: Mixture-of-Agents Beats Frontier Models",
        subheadline: "Virtual models using MoA presets outperform Opus 4.8 & GPT-5.5",
        summary: "Hermes Agent team demonstrates that clever orchestration of multiple agents can surpass the best publicly available frontier models on internal benchmarks. Includes impressive video demo.",
        author: "Nous Research",
        handle: "@NousResearch",
        timestamp: "12h ago",
        likes: 9800,
        xURL: "https://x.com/NousResearch/status/2070610321278988385",
        category: "Agents",
        isHero: false
    ),
    Article(
        headline: "Massive Free AI Course Vault Shared on X",
        subheadline: "70-119GB collections of paid courses on LLMs, agents & more",
        summary: "Popular accounts are distributing enormous Google Drive archives containing courses on Prompt Engineering, Claude, Grok, Data Science, and ethical hacking. Spanish-language Claude deep-dives also trending.",
        author: "Alex Moore",
        handle: "@heyalexmoore",
        timestamp: "1d ago",
        likes: 6700,
        xURL: "https://x.com/heyalexmoore/status/2070857558886351096",
        category: "Community",
        isHero: false
    )
]

// MARK: - Main Content View
struct ContentView: View {
    @State private var articles: [Article] = sampleArticles
    @State private var selectedArticle: Article? = nil
    @State private var showingRefreshAlert = false
    @State private var currentDate = Date()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // MARK: - Masthead (Newspaper Style)
                    VStack(spacing: 4) {
                        Text("THE AETHER DAILY")
                            .font(.system(size: 42, weight: .black, design: .serif))
                            .tracking(4)
                            .foregroundStyle(.primary)
                        
                        Text("The Premier Source for AI Developments")
                            .font(.system(size: 14, weight: .medium, design: .serif))
                            .foregroundStyle(.secondary)
                            .italic()
                        
                        HStack {
                            Text(dateFormatter.string(from: currentDate).uppercased())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Text("EDITION 284 • \(articles.count) STORIES")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    .background(Color(.systemBackground))
                    
                    Divider()
                    
                    // MARK: - Hero Story
                    if let hero = articles.first(where: { $0.isHero }) {
                        HeroArticleView(article: hero)
                            .onTapGesture {
                                selectedArticle = hero
                            }
                    }
                    
                    // MARK: - Front Page Section Header
                    SectionHeader(title: "FRONT PAGE")
                    
                    // Other articles
                    ForEach(articles.filter { !$0.isHero }) { article in
                        ArticleRowView(article: article)
                            .onTapGesture {
                                selectedArticle = article
                            }
                        
                        Divider()
                            .padding(.horizontal)
                    }
                    
                    // MARK: - Categories
                    SectionHeader(title: "MODELS & RESEARCH")
                    
                    ForEach(articles.filter { $0.category == "Models" || $0.category == "Research" }) { article in
                        if !article.isHero {
                            ArticleRowView(article: article)
                                .onTapGesture { selectedArticle = article }
                            Divider().padding(.horizontal)
                        }
                    }
                    
                    SectionHeader(title: "AGENTS & TOOLS")
                    
                    ForEach(articles.filter { $0.category == "Agents" || $0.category == "Tools" }) { article in
                        if !article.isHero {
                            ArticleRowView(article: article)
                                .onTapGesture { selectedArticle = article }
                            Divider().padding(.horizontal)
                        }
                    }
                    
                    // Footer
                    VStack(spacing: 8) {
                        Text("Sourced primarily from X (formerly Twitter)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        
                        Button {
                            refreshFromX()
                        } label: {
                            Label("Refresh from X", systemImage: "arrow.clockwise")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .tint(.accentColor)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(item: $selectedArticle) { article in
                ArticleDetailView(article: article)
            }
            .alert("Refresh from X", isPresented: $showingRefreshAlert) {
                Button("OK") { }
            } message: {
                Text("In a production app this would call the X API v2. Currently showing latest seeded data from real high-engagement posts.")
            }
        }
        .preferredColorScheme(.light) // Newspaper feel
    }
    
    private func refreshFromX() {
        // Simulate refresh - in real app this would call X API
        withAnimation {
            currentDate = Date()
            // Shuffle or add new mock for demo
            articles = sampleArticles.shuffled()
        }
        showingRefreshAlert = true
    }
}

// MARK: - Hero Article View
struct HeroArticleView: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Placeholder for image
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: [.blue.opacity(0.15), .purple.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 220)
                
                VStack {
                    Image(systemName: "newspaper.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary.opacity(0.4))
                    
                    Text("BREAKING")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .clipShape(Capsule())
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
            )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(article.headline)
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .lineLimit(3)
                
                Text(article.subheadline)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .italic()
                
                HStack {
                    Text(article.author)
                        .fontWeight(.semibold)
                    Text("• \(article.timestamp)")
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Label("\(article.likes.formatted())", systemImage: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                .font(.subheadline)
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 16)
    }
}

// MARK: - Article Row
struct ArticleRowView: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(article.category.uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Capsule())
                
                Spacer()
                
                Label("\(article.likes.formatted())", systemImage: "heart.fill")
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
            
            Text(article.headline)
                .font(.system(size: 20, weight: .bold, design: .serif))
                .lineLimit(2)
            
            Text(article.summary)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(3)
            
            HStack {
                Text("\(article.author)  •  \(article.timestamp)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(article.handle)
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .black, design: .serif))
            .tracking(2)
            .foregroundStyle(.primary)
            .padding(.horizontal)
            .padding(.top, 24)
            .padding(.bottom, 8)
    }
}

// MARK: - Article Detail View (Sheet)
struct ArticleDetailView: View {
    let article: Article
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(article.headline)
                            .font(.system(size: 32, weight: .bold, design: .serif))
                            .lineLimit(nil)
                        
                        Text(article.subheadline)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .italic()
                    }
                    
                    // Byline
                    HStack {
                        VStack(alignment: .leading) {
                            Text(article.author)
                                .fontWeight(.semibold)
                            Text(article.handle)
                                .foregroundStyle(.blue)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text(article.timestamp)
                            Label("\(article.likes.formatted()) likes", systemImage: "heart.fill")
                                .foregroundStyle(.red)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical)
                    
                    Divider()
                    
                    // Body
                    Text(article.summary)
                        .font(.body)
                        .lineSpacing(6)
                    
                    // Source
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PRIMARY SOURCE")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .tracking(1)
                        
                        Button {
                            if let url = URL(string: article.xURL) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "bird.fill")
                                Text("View Original Post on X")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundStyle(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Article")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}