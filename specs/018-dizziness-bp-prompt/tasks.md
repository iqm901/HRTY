# Tasks: Dizziness + BP Check Prompt

## HealthKit BP Integration
- [ ] Add blood pressure to HealthKit authorization
- [ ] Add method to fetch recent BP readings
- [ ] Check for BP data in last 24 hours
- [ ] Handle no BP data case

## Prompt Logic
- [ ] Check dizziness severity after symptom save
- [ ] Trigger if dizziness ≥ 3
- [ ] Check for recent BP data
- [ ] Only show prompt if no BP available

## Prompt Content
- [ ] Create warm, helpful prompt message
- [ ] Suggest manual BP check
- [ ] Include orthostatic precaution tip
- [ ] Mention contacting clinician option

## UI Component
- [ ] Create BP prompt banner/card
- [ ] Use consistent styling with other alerts
- [ ] Add dismiss button
- [ ] Show after symptom save

## TodayView Integration
- [ ] Add BP prompt display area
- [ ] Show when conditions met
- [ ] Handle dismissal
- [ ] Don't show if BP data exists

## Quality Checks
- [ ] Prompt shows at dizziness ≥ 3
- [ ] Prompt doesn't show if BP available
- [ ] Message is warm and helpful
- [ ] Dismiss works correctly
- [ ] App builds without errors
