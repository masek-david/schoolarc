package com.example.myapp

import HomeWidgetGlanceState
import HomeWidgetGlanceStateDefinition
import Meal
import MealDay
import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.lazy.LazyColumn
import androidx.glance.appwidget.lazy.items
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.padding
import androidx.glance.state.GlanceStateDefinition
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

class StravaWidget : GlanceAppWidget() {

    override val stateDefinition: GlanceStateDefinition<*>
        get() = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            GlanceTheme {
                GlanceContent(context, currentState())
            }
        }
    }

    @Composable
    private fun GlanceContent(context: Context, currentState: HomeWidgetGlanceState) {
        val meals: MutableList<MealDay> = mutableListOf()
        val data = currentState.preferences

        val json = data.getString("meals", null)

        val type = object : TypeToken<Map<String, List<Meal>>>() {}.type
        if (json != null) {
            val map: Map<String, List<Meal>> = Gson().fromJson(json, type)

            map.forEach { (key, value) ->
                meals.add(MealDay(key, value))
            }
        }

        if (meals.isEmpty()) {
            Box(
                modifier = GlanceModifier.background(GlanceTheme.colors.widgetBackground)
                    .fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    "No meals found",
                    style = TextStyle(color = GlanceTheme.colors.onBackground)
                )
            }
            return
        }

        Box(modifier = GlanceModifier.background(GlanceTheme.colors.widgetBackground)) {
            LazyColumn {
                items(meals) { mealDay ->
                    Box(
                        modifier = GlanceModifier.padding(horizontal = 8.dp).padding(top = 8.dp)
                    ) {
                        Column(
                            modifier = GlanceModifier.padding(all = 8.dp).cornerRadius(8.dp)
                                .background(GlanceTheme.colors.surface)
                        ) {
                            Text(
                                mealDay.date,
                                modifier = GlanceModifier.fillMaxWidth(),
                                style = TextStyle(
                                    textAlign = TextAlign.Center,
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 16.sp,
                                    color = GlanceTheme.colors.onPrimaryContainer
                                )
                            )
                            mealDay.meals.forEach { meal ->
                                Column(
                                    modifier = GlanceModifier.background(if (meal.selected) GlanceTheme.colors.tertiaryContainer else GlanceTheme.colors.surface)
                                        .padding(all = 4.dp).cornerRadius(8.dp).fillMaxWidth()
                                ) {
                                    Text(
                                        meal.type, style = TextStyle(
                                            fontWeight = FontWeight.Medium,
                                            color = GlanceTheme.colors.onBackground
                                        )
                                    )
                                    Text(
                                        meal.name, style = TextStyle(
                                            color = GlanceTheme.colors.onBackground
                                        )
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}