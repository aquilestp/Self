# Fix activity name overflow in widget drawer previews

**Problem**
When an activity has a long name, the mini widget previews in the drawer overflow their containers.

**Fix**

- [x] `miniStat` helper — `lineLimit(1)` on value text
- [x] Stack widget case — `lineLimit(1)` on value text
- [x] `.bold` else branch — `lineLimit(1)` + `truncationMode(.tail)` on `activity.title`
- [x] `.impact` else branch — `lineLimit(1)` + `truncationMode(.tail)` on `activity.title`
- [x] `widgetThumbnail` container — `.clipShape(.rect(cornerRadius: 14))` to hard-clip any overflow
- [x] `fullWidthThumbnail` container — `.clipShape(.rect(cornerRadius: 14))` to hard-clip any overflow
