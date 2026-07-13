# Step 3: Test & Optimize

**Workflow:** build-dashboard
**Phase:** Quality Assurance
**Duration:** 4-8 hours

---

## Objective

UX testing, performance profiling, and responsiveness verification.

---

## Instructions

Act as Marie with quality assurance mindset. Ensure dashboard is production-ready.

### 1. Functional Testing

Test all features:
- [ ] All filters work and update outputs
- [ ] KPIs calculate correctly
- [ ] Plots render without errors
- [ ] Tables display properly
- [ ] Downloads work (CSV, PNG)
- [ ] Navigation works (tabs, links)

### 2. Performance Profiling

Use `profvis` to identify bottlenecks:
```r
profvis::profvis({
  shiny::runApp()
  # Interact with dashboard
})
```

Optimize:
- Cache expensive computations
- Reduce data size if needed
- Async processing for slow queries
- Optimize plot rendering

### 3. UX Testing

Test user experience:
- Initial load time < 5 seconds
- Filter updates feel responsive (< 1 second)
- Layout clear and intuitive
- KPIs prominently displayed
- Error messages helpful (not "Error in eval()")

### 4. Responsive Design

Test on different devices:
- Desktop (large screen)
- Tablet (medium screen)
- Mobile (small screen)

Verify layout adapts gracefully.

### 5. Edge Case Testing

Test with:
- Empty filtered datasets → Show "No data" message
- Large datasets → Verify performance acceptable
- Missing values → Handle gracefully
- Date range edge cases → Validate logic

### 6. Browser Compatibility

Test in:
- Chrome/Edge (Chromium)
- Firefox
- Safari

---

## Validation Checklist

Before proceeding to Step 4:
- [ ] All features tested and working
- [ ] Performance acceptable (< 3s filter updates)
- [ ] Responsive on mobile/tablet/desktop
- [ ] Edge cases handled gracefully
- [ ] No console errors or warnings

---

## Output

**Artifacts:**
- Performance profile results
- Bug fixes applied
- UX improvements implemented

**Next:** Proceed to Step 4 (Deploy)
