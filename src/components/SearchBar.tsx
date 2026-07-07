"use client";

import { useState, useEffect, useMemo, useCallback, useRef } from "react";
import SearchResultCard from "./SearchResultCard";
import styles from "./SearchBar.module.css";

const TYPE_LABELS: Record<string, string> = {
  charts: "Charts",
  datasets: "Datasets",
  packages: "Packages",
  projects: "Projects",
  resources: "Resources",
};

interface SearchItem {
  type: string;
  slug: string;
  title: string;
  description?: string | null;
  author?: string | null;
  date?: string | null;
  categories: string[];
  tags: string[];
  featured: boolean;
  url: string;
}

interface SearchIndex {
  items: SearchItem[];
  facets: {
    types: string[];
    categories: string[];
    tags: string[];
  };
  generatedAt: string;
}

interface SearchBarProps {
  /** Pre-selected content type filter for page context */
  defaultTypeFilter?: string;
}

export default function SearchBar({ defaultTypeFilter }: SearchBarProps) {
  const [index, setIndex] = useState<SearchIndex | null>(null);
  const [query, setQuery] = useState("");
  const [activeTypes, setActiveTypes] = useState<Set<string>>(
    defaultTypeFilter ? new Set([defaultTypeFilter]) : new Set()
  );
  const [selectedCategories, setSelectedCategories] = useState<Set<string>>(
    new Set()
  );
  const [selectedTags, setSelectedTags] = useState<Set<string>>(new Set());
  const [showCategoryDropdown, setShowCategoryDropdown] = useState(false);
  const [showTagDropdown, setShowTagDropdown] = useState(false);
  const [debouncedQuery, setDebouncedQuery] = useState("");
  const [engaged, setEngaged] = useState(false);

  const searchInputRef = useRef<HTMLInputElement>(null);
  const categoryRef = useRef<HTMLDivElement>(null);
  const tagRef = useRef<HTMLDivElement>(null);

  // Fetch index on mount
  useEffect(() => {
    // fetch("/content/search-index.json") // <- breaks in production
    const basePath = process.env.NEXT_PUBLIC_BASE_PATH || "";
    fetch(`${basePath}/content/search-index.json`)
      .then((res) => res.json())
      .then((data) => setIndex(data))
      .catch((err) => console.error("Failed to load search index:", err));
  }, []);

  // Debounce query input
  useEffect(() => {
    const timer = setTimeout(() => setDebouncedQuery(query), 300);
    return () => clearTimeout(timer);
  }, [query]);

  // Close dropdowns on outside click
  useEffect(() => {
    function handleClick(e: MouseEvent) {
      if (
        categoryRef.current &&
        !categoryRef.current.contains(e.target as Node)
      ) {
        setShowCategoryDropdown(false);
      }
      if (tagRef.current && !tagRef.current.contains(e.target as Node)) {
        setShowTagDropdown(false);
      }
    }
    document.addEventListener("mousedown", handleClick);
    return () => document.removeEventListener("mousedown", handleClick);
  }, []);

  // Keyboard shortcuts
  useEffect(() => {
    function handleKey(e: KeyboardEvent) {
      if (e.key === "/" && !["INPUT", "TEXTAREA"].includes(document.activeElement?.tagName || "")) {
        e.preventDefault();
        searchInputRef.current?.focus();
      }
      if (e.key === "Escape") {
        setQuery("");
        setActiveTypes(defaultTypeFilter ? new Set([defaultTypeFilter]) : new Set());
        setSelectedCategories(new Set());
        setSelectedTags(new Set());
        setEngaged(false);
        searchInputRef.current?.blur();
      }
    }
    document.addEventListener("keydown", handleKey);
    return () => document.removeEventListener("keydown", handleKey);
  }, [defaultTypeFilter]);

  // Filter logic
  const filteredItems = useMemo(() => {
    if (!index) return [];

    let items = index.items;

    // Type filter
    if (activeTypes.size > 0) {
      items = items.filter((item) => activeTypes.has(item.type));
    }

    // Category filter
    if (selectedCategories.size > 0) {
      items = items.filter((item) =>
        item.categories.some((c) => selectedCategories.has(c))
      );
    }

    // Tag filter
    if (selectedTags.size > 0) {
      items = items.filter((item) =>
        item.tags.some((t) => selectedTags.has(t))
      );
    }

    // Text search
    if (debouncedQuery.trim()) {
      const q = debouncedQuery.toLowerCase().trim();
      items = items.filter(
        (item) =>
          item.title.toLowerCase().includes(q) ||
          (item.description && item.description.toLowerCase().includes(q))
      );
    }

    return items;
  }, [index, activeTypes, selectedCategories, selectedTags, debouncedQuery]);

  const hasActiveFilters =
    activeTypes.size > 0 ||
    selectedCategories.size > 0 ||
    selectedTags.size > 0 ||
    debouncedQuery.trim().length > 0;

  const toggleType = useCallback((type: string) => {
    if (!engaged) setEngaged(true);
    setActiveTypes((prev) => {
      const next = new Set(prev);
      if (next.has(type)) {
        next.delete(type);
      } else {
        next.add(type);
      }
      return next;
    });
  }, [engaged]);

  const toggleCategory = useCallback((cat: string) => {
    if (!engaged) setEngaged(true);
    setSelectedCategories((prev) => {
      const next = new Set(prev);
      if (next.has(cat)) {
        next.delete(cat);
      } else {
        next.add(cat);
      }
      return next;
    });
  }, []);

  const toggleTag = useCallback((tag: string) => {
    if (!engaged) setEngaged(true);
    setSelectedTags((prev) => {
      const next = new Set(prev);
      if (next.has(tag)) {
        next.delete(tag);
      } else {
        next.add(tag);
      }
      return next;
    });
  }, []);

  const clearAll = useCallback(() => {
    setQuery("");
    setDebouncedQuery("");
    setActiveTypes(defaultTypeFilter ? new Set([defaultTypeFilter]) : new Set());
    setSelectedCategories(new Set());
    setSelectedTags(new Set());
    setEngaged(false);
  }, [defaultTypeFilter]);

  if (!index) return null;

  const totalActiveFilters =
    activeTypes.size +
    selectedCategories.size +
    selectedTags.size +
    (debouncedQuery.trim() ? 1 : 0);

  return (
    <div className={styles.searchBar}>
      <div className={styles.inner}>
        {/* Search input */}
        <div className={styles.searchRow}>
          <div className={styles.inputWrapper}>
            <svg
              className={styles.searchIcon}
              width="18"
              height="18"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <circle cx="11" cy="11" r="8" />
              <line x1="21" y1="21" x2="16.65" y2="16.65" />
            </svg>
            <input
              ref={searchInputRef}
              type="text"
              className={styles.searchInput}
              placeholder="Search datasets, charts, packages, projects..."
              value={query}
              onChange={(e) => {
                if (!engaged && e.target.value.trim()) setEngaged(true);
                setQuery(e.target.value);
              }}
              aria-label="Search content"
            />
            {(query || totalActiveFilters > 0) && (
              <button
                className={styles.clearBtn}
                onClick={() => setQuery("")}
                aria-label="Clear search"
              >
                &times;
              </button>
            )}
          </div>

          <span className={styles.hint}>Press / to focus</span>
        </div>

        {/* Filter row — only shown after user engages with search */}
        {engaged && (
        <div className={styles.filterRow}>
          {/* Content type pills */}
          <div className={styles.filterGroup}>
            <span className={styles.filterLabel}>Type</span>
            <div className={styles.pills}>
              {index.facets.types.map((type) => (
                <button
                  key={type}
                  className={`${styles.pill} ${
                    activeTypes.has(type) ? styles.pillActive : ""
                  }`}
                  onClick={() => toggleType(type)}
                >
                  {TYPE_LABELS[type] || type}
                </button>
              ))}
            </div>
          </div>

          {/* Category filter */}
          <div className={styles.filterGroup} ref={categoryRef}>
            <span className={styles.filterLabel}>Category</span>
            <div className={styles.dropdownWrapper}>
              <button
                className={`${styles.dropdownTrigger} ${
                  selectedCategories.size > 0 ? styles.dropdownActive : ""
                }`}
                onClick={() => setShowCategoryDropdown(!showCategoryDropdown)}
                aria-expanded={showCategoryDropdown}
              >
                {selectedCategories.size > 0
                  ? `${selectedCategories.size} selected`
                  : "All"}
                <svg
                  width="12"
                  height="12"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2.5"
                  style={{
                    marginLeft: 4,
                    transform: showCategoryDropdown
                      ? "rotate(180deg)"
                      : "none",
                    transition: "transform 0.15s",
                  }}
                >
                  <polyline points="6 9 12 15 18 9" />
                </svg>
              </button>
              {showCategoryDropdown && (
                <div className={styles.dropdownMenu}>
                  {index.facets.categories.map((cat) => (
                    <label key={cat} className={styles.dropdownItem}>
                      <input
                        type="checkbox"
                        checked={selectedCategories.has(cat)}
                        onChange={() => toggleCategory(cat)}
                      />
                      <span>{cat}</span>
                    </label>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Tag filter */}
          <div className={styles.filterGroup} ref={tagRef}>
            <span className={styles.filterLabel}>Tags</span>
            <div className={styles.dropdownWrapper}>
              <button
                className={`${styles.dropdownTrigger} ${
                  selectedTags.size > 0 ? styles.dropdownActive : ""
                }`}
                onClick={() => setShowTagDropdown(!showTagDropdown)}
                aria-expanded={showTagDropdown}
              >
                {selectedTags.size > 0
                  ? `${selectedTags.size} selected`
                  : "All"}
                <svg
                  width="12"
                  height="12"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2.5"
                  style={{
                    marginLeft: 4,
                    transform: showTagDropdown ? "rotate(180deg)" : "none",
                    transition: "transform 0.15s",
                  }}
                >
                  <polyline points="6 9 12 15 18 9" />
                </svg>
              </button>
              {showTagDropdown && (
                <div className={`${styles.dropdownMenu} ${styles.tagMenu}`}>
                  {index.facets.tags.map((tag) => (
                    <label key={tag} className={styles.dropdownItem}>
                      <input
                        type="checkbox"
                        checked={selectedTags.has(tag)}
                        onChange={() => toggleTag(tag)}
                      />
                      <span>{tag}</span>
                    </label>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Clear all */}
          {totalActiveFilters > 0 && (
            <button className={styles.clearAllBtn} onClick={clearAll}>
              Clear all ({totalActiveFilters})
            </button>
          )}
        </div>
        )}

        {/* Active filter chips */}
        {hasActiveFilters && (
          <div className={styles.activeChips}>
            {[...activeTypes].map((t) => (
              <span
                key={t}
                className={styles.chip}
                onClick={() => toggleType(t)}
              >
                {TYPE_LABELS[t] || t}
                <small>&times;</small>
              </span>
            ))}
            {[...selectedCategories].map((c) => (
              <span
                key={c}
                className={styles.chip}
                onClick={() => toggleCategory(c)}
              >
                {c}
                <small>&times;</small>
              </span>
            ))}
            {[...selectedTags].map((t) => (
              <span
                key={t}
                className={styles.chip}
                onClick={() => toggleTag(t)}
              >
                {t}
                <small>&times;</small>
              </span>
            ))}
          </div>
        )}

        {/* Results */}
        {hasActiveFilters && (
          <div className={styles.resultsSection}>
            <p className={styles.resultCount}>
              {filteredItems.length} result{filteredItems.length !== 1 ? "s" : ""}
              {debouncedQuery.trim() && (
                <> for &ldquo;{debouncedQuery.trim()}&rdquo;</>
              )}
            </p>
            {filteredItems.length > 0 ? (
              <div className={styles.resultsGrid}>
                {filteredItems.map((item) => (
                  <SearchResultCard
                    key={`${item.type}-${item.slug}`}
                    type={item.type}
                    title={item.title}
                    description={item.description}
                    categories={item.categories}
                    date={item.date}
                    url={item.url}
                  />
                ))}
              </div>
            ) : (
              <div className={styles.emptyState}>
                <p>No matching content found.</p>
                <button className={styles.resetLink} onClick={clearAll}>
                  Clear all filters
                </button>
              </div>
            )}
          </div>
        )}

        {/* Footer spacing */}
        {hasActiveFilters && (
          <div className={styles.searchFooter} />
        )}
      </div>
    </div>
  );
}
