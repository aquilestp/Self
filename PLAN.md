# Fix drawer widget sorting stability

## Problem

The sorted widget list is recomputed on every view render. During the transition between half-open and fully-open drawer states, both drawer views exist simultaneously (opacity animation), each recalculating the sort independently — causing the visible order to jump.

## Fix

- Store the sorted widget order in a single stable list that is only recalculated when the sorting criteria actually change (tab switch between Popular/Recents, or when popularity/recency data loads)
- Both the compact drawer and the expanded drawer will read from this same stable list — no more divergence during transitions
- The order will remain locked throughout the open/expand animation and only change intentionally when the user taps Popular or Recents tabs

