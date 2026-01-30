import SwiftUI
import SwiftData

struct FoodSearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: SodiumViewModel

    @State private var searchQuery = ""
    @State private var searchResults: [BundledFoodItem] = []
    @State private var selectedCategory: BundledFoodCategory?
    @FocusState private var isSearchFocused: Bool

    // Recent and favorites state
    @State private var recentFoods: [BundledFoodItem] = []
    @State private var favoriteFoods: [BundledFoodItem] = []
    @State private var favoriteIds: Set<String> = []

    private let database = BundledFoodDatabaseService.shared

    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            searchBar
                .padding(.horizontal, HRTSpacing.md)
                .padding(.vertical, HRTSpacing.sm)

            // Category Pills
            categoryPills
                .padding(.bottom, HRTSpacing.sm)

            // Results
            if searchQuery.isEmpty && selectedCategory == nil {
                defaultBrowseView
            } else if searchResults.isEmpty {
                emptyState
            } else {
                resultsList
            }
        }
        .background(Color.hrtBackgroundFallback)
        .navigationTitle("Search Foods")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .onAppear {
            isSearchFocused = true
            loadRecentAndFavorites()
        }
        .onChange(of: searchQuery) { _, newValue in
            performSearch()
        }
        .onChange(of: selectedCategory) { _, _ in
            performSearch()
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: HRTSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.hrtTextTertiaryFallback)

            TextField("Search foods, restaurants...", text: $searchQuery)
                .textFieldStyle(.plain)
                .font(.hrtBody)
                .autocorrectionDisabled()
                .focused($isSearchFocused)

            if !searchQuery.isEmpty {
                Button {
                    searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.hrtTextTertiaryFallback)
                }
            }
        }
        .padding(.horizontal, HRTSpacing.sm)
        .padding(.vertical, 10)
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.small))
    }

    // MARK: - Category Pills

    private var categoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HRTSpacing.sm) {
                // All Foods pill
                categoryPill(title: "All", category: nil)

                ForEach(database.availableCategories(), id: \.self) { category in
                    categoryPill(title: category.displayName, category: category)
                }
            }
            .padding(.horizontal, HRTSpacing.md)
        }
    }

    private func categoryPill(title: String, category: BundledFoodCategory?) -> some View {
        let isSelected = selectedCategory == category

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if selectedCategory == category {
                    selectedCategory = nil
                } else {
                    selectedCategory = category
                }
            }
        } label: {
            Text(title)
                .font(.hrtCaption)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundStyle(isSelected ? Color.white : Color.hrtTextSecondaryFallback)
                .padding(.horizontal, HRTSpacing.sm)
                .padding(.vertical, 6)
                .background(isSelected ? Color.hrtPinkFallback : Color.hrtCardFallback)
                .clipShape(Capsule())
        }
    }

    // MARK: - Default Browse View (Recent, Favorites, Browse Prompt)

    private var defaultBrowseView: some View {
        ScrollView {
            VStack(spacing: HRTSpacing.lg) {
                // Recent Foods Section
                if !recentFoods.isEmpty {
                    recentFoodsSection
                }

                // Favorites Section
                if !favoriteFoods.isEmpty {
                    favoritesSection
                }

                // Browse Prompt
                browsePrompt
            }
            .padding(.bottom, HRTSpacing.lg)
        }
    }

    // MARK: - Recent Foods Section

    private var recentFoodsSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            Text("Recent")
                .font(.hrtSubheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.hrtTextFallback)
                .padding(.horizontal, HRTSpacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HRTSpacing.sm) {
                    ForEach(recentFoods) { food in
                        FoodChip(
                            food: food,
                            isFavorite: favoriteIds.contains(food.id),
                            onTap: { addFood(food) },
                            onFavoriteToggle: { toggleFavorite(food) }
                        )
                    }
                }
                .padding(.horizontal, HRTSpacing.md)
            }
        }
    }

    // MARK: - Favorites Section

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            Text("Favorites")
                .font(.hrtSubheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.hrtTextFallback)
                .padding(.horizontal, HRTSpacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HRTSpacing.sm) {
                    ForEach(favoriteFoods) { food in
                        FoodChip(
                            food: food,
                            isFavorite: true,
                            onTap: { addFood(food) },
                            onFavoriteToggle: { toggleFavorite(food) }
                        )
                    }
                }
                .padding(.horizontal, HRTSpacing.md)
            }
        }
    }

    // MARK: - Browse Prompt

    private var browsePrompt: some View {
        VStack(spacing: HRTSpacing.lg) {
            Spacer()
                .frame(height: HRTSpacing.xl)

            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(Color.hrtTextTertiaryFallback)

            VStack(spacing: HRTSpacing.xs) {
                Text("Search \(database.totalFoodCount) Foods")
                    .font(.hrtHeadline)
                    .foregroundStyle(Color.hrtTextFallback)

                Text("Search for packaged foods, restaurant items, and more")
                    .font(.hrtCaption)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .multilineTextAlignment(.center)
            }

            Spacer()
                .frame(height: HRTSpacing.xl)
        }
        .padding(.horizontal, HRTSpacing.xl)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: HRTSpacing.md) {
            Spacer()

            Image(systemName: "fork.knife.circle")
                .font(.system(size: 48))
                .foregroundStyle(Color.hrtTextTertiaryFallback)

            Text("No foods found")
                .font(.hrtHeadline)
                .foregroundStyle(Color.hrtTextFallback)

            Text("Try a different search term or browse by category")
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(.horizontal, HRTSpacing.xl)
    }

    // MARK: - Results List

    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(searchResults) { food in
                    FoodSearchRow(
                        food: food,
                        isFavorite: favoriteIds.contains(food.id),
                        onTap: { addFood(food) },
                        onFavoriteToggle: { toggleFavorite(food) }
                    )

                    if food.id != searchResults.last?.id {
                        Divider()
                            .padding(.leading, 56)
                    }
                }
            }
            .background(Color.hrtCardFallback)
            .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
            .padding(.horizontal, HRTSpacing.md)
            .padding(.bottom, HRTSpacing.lg)
        }
    }

    // MARK: - Actions

    private func performSearch() {
        if let category = selectedCategory {
            if searchQuery.isEmpty {
                searchResults = database.foodsByCategory(category)
            } else {
                // Filter by both category and search
                searchResults = database.searchFoods(query: searchQuery)
                    .filter { $0.category == category }
            }
        } else if !searchQuery.isEmpty {
            searchResults = database.searchFoods(query: searchQuery)
        } else {
            searchResults = []
        }
    }

    private func addFood(_ food: BundledFoodItem) {
        viewModel.addFromBundledFood(food, context: modelContext)
        dismiss()
    }

    private func loadRecentAndFavorites() {
        // Load recent food IDs and resolve to BundledFoodItems
        let recentIds = SodiumEntry.fetchRecentBundledFoodIds(limit: 10, in: modelContext)
        recentFoods = database.foods(byIds: recentIds)

        // Load favorite IDs and resolve to BundledFoodItems
        let favIds = FoodFavorite.allFavoriteIds(in: modelContext)
        favoriteIds = Set(favIds)
        favoriteFoods = database.foods(byIds: favIds)
    }

    private func toggleFavorite(_ food: BundledFoodItem) {
        let isNowFavorite = FoodFavorite.toggle(bundledFoodId: food.id, in: modelContext)

        // Update local state
        if isNowFavorite {
            favoriteIds.insert(food.id)
            if !favoriteFoods.contains(where: { $0.id == food.id }) {
                favoriteFoods.insert(food, at: 0)
            }
        } else {
            favoriteIds.remove(food.id)
            favoriteFoods.removeAll { $0.id == food.id }
        }
    }
}

// MARK: - Food Search Row

private struct FoodSearchRow: View {
    let food: BundledFoodItem
    let isFavorite: Bool
    let onTap: () -> Void
    let onFavoriteToggle: () -> Void

    var body: some View {
        HStack(spacing: HRTSpacing.md) {
            // Category Icon
            ZStack {
                Circle()
                    .fill(Color.hrtPinkLightFallback)
                    .frame(width: 40, height: 40)

                Image(systemName: food.category.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.hrtPinkFallback)
            }

            // Name and Details
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(food.displayName)
                        .font(.hrtBody)
                        .foregroundStyle(Color.hrtTextFallback)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(food.servingSize)
                        .font(.hrtCaption)
                        .foregroundStyle(Color.hrtTextTertiaryFallback)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            // Favorite Button
            Button(action: onFavoriteToggle) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 18))
                    .foregroundStyle(isFavorite ? Color.hrtPinkFallback : Color.hrtTextTertiaryFallback)
            }
            .buttonStyle(.plain)
            .padding(.trailing, HRTSpacing.xs)

            // Sodium Amount + Add Button
            Button(action: onTap) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(SodiumConstants.formatSodium(food.sodiumMg))
                        .font(.hrtBody)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.hrtTextFallback)

                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.hrtPinkFallback)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, HRTSpacing.md)
        .padding(.vertical, HRTSpacing.sm)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(food.displayName), \(food.sodiumMg) milligrams, \(food.servingSize)")
        .accessibilityHint("Double tap to add to today's log")
    }
}

// MARK: - Food Chip (for Recent/Favorites horizontal scroll)

private struct FoodChip: View {
    let food: BundledFoodItem
    let isFavorite: Bool
    let onTap: () -> Void
    let onFavoriteToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.xs) {
            HStack(spacing: HRTSpacing.xs) {
                Text(food.displayName)
                    .font(.hrtCaption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.hrtTextFallback)
                    .lineLimit(1)

                Spacer(minLength: 4)

                Button(action: onFavoriteToggle) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 12))
                        .foregroundStyle(isFavorite ? Color.hrtPinkFallback : Color.hrtTextTertiaryFallback)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: HRTSpacing.xs) {
                Text(SodiumConstants.formatSodium(food.sodiumMg))
                    .font(.hrtCaption)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)

                Spacer(minLength: 4)

                Button(action: onTap) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.hrtPinkFallback)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, HRTSpacing.sm)
        .padding(.vertical, HRTSpacing.sm)
        .frame(width: 140)
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.small))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(food.displayName), \(food.sodiumMg) milligrams")
        .accessibilityHint("Double tap to add to today's log")
    }
}

#Preview {
    NavigationStack {
        FoodSearchView(viewModel: SodiumViewModel())
    }
    .modelContainer(for: [SodiumEntry.self, SodiumTemplate.self, FoodFavorite.self], inMemory: true)
}
