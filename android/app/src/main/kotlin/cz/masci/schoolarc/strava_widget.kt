package cz.masci.schoolarc

import HomeWidgetGlanceState
import HomeWidgetGlanceStateDefinition
import Meal
import MealDay
import Task
import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.net.toUri
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.action.clickable
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
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.state.GlanceStateDefinition
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import es.antonborri.home_widget.actionStartActivity
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.Locale

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

    private fun formatDate(date: LocalDate): String {
        if (date.isEqual(LocalDate.now())) {
            return today
        }
        if (date.isEqual(LocalDate.now().plusDays(1))) {
            return tomorrow
        }

        val finalFormat = "EEE, " + if (LocalDate.now().year == date.year) shortFormat else format

        return date.format(
            DateTimeFormatter.ofPattern(finalFormat).withLocale(Locale.forLanguageTag(locale))
        )
    }

    var format = "d. MMM yyyy"
    var shortFormat = "d. MMM"
    var locale = "en"
    var today = "Today"
    var tomorrow = "Tomorrow"
    var noMealsFound = "No meals found"

    @Composable
    private fun GlanceContent(context: Context, currentState: HomeWidgetGlanceState) {
        var meals: MutableList<MealDay> = mutableListOf()
        val isDebug = false
        if (isDebug) {
            meals = mutableListOf(
                MealDay(
                    date = LocalDate.of(2025, 11, 1), meals = listOf(
                        Meal(type = "Soup", name = "Tomato soup with croutons", selected = false),
                        Meal(
                            type = "Meal 1",
                            name = "Chicken schnitzel with mashed potatoes",
                            selected = true
                        ),
                        Meal(type = "Meal 2", name = "Vegetable risotto", selected = false),
                        Meal(type = "Dessert", name = "Apple strudel", selected = false)
                    )
                ),
                MealDay(
                    date = LocalDate.of(2025, 11, 2), meals = listOf(
                        Meal(type = "Soup", name = "Tomato soup with croutons", selected = false),
                        Meal(
                            type = "Meal 1",
                            name = "Chicken schnitzel with mashed potatoes",
                            selected = true
                        ),
                        Meal(type = "Meal 2", name = "Vegetable risotto", selected = false),
                        Meal(type = "Dessert", name = "Apple strudel", selected = false)
                    )
                ),
            )
        } else {
            val data = currentState.preferences

            val locJson = data.getString("loc", null)

            if (locJson != null) {
                val loc = Gson().fromJson<Map<String, String>>(
                    locJson, object : TypeToken<Map<String, String>>() {}.type
                )
                today = loc["today"] ?: today
                tomorrow = loc["tomorrow"] ?: tomorrow
                locale = loc["locale"] ?: locale
                format = loc["format"] ?: format
                shortFormat = loc["shortFormat"] ?: shortFormat
                noMealsFound = loc["noMealsFound"] ?: noMealsFound
            }

            val json = data.getString("meals", null)

            val type = object : TypeToken<Map<String, List<Meal>>>() {}.type
            if (json != null) {
                val map: Map<String, List<Meal>> = Gson().fromJson(json, type)

                map.forEach { (key, value) ->
                    meals.add(MealDay(dateFromPrimitiveDate(key.toInt()), value))
                }
            }
        }

        if (meals.isEmpty()) {
            Box(
                modifier = GlanceModifier.background(GlanceTheme.colors.widgetBackground)
                    .fillMaxSize(), contentAlignment = Alignment.Center
            ) {
                Text(
                    noMealsFound, style = TextStyle(color = GlanceTheme.colors.onBackground)
                )
            }
            return
        }

        Box(
            modifier = GlanceModifier.background(GlanceTheme.colors.widgetBackground)
                .cornerRadius(24.dp)
        ) {
            LazyColumn {
                items(meals) { mealDay ->
                    if (!mealDay.date.isBefore(LocalDate.now())) {
                        Box(
                            modifier = GlanceModifier.padding(horizontal = 8.dp).padding(top = 8.dp)
                                .clickable(
                                    actionStartActivity<MainActivity>(
                                        context, "schoolarc://meals".toUri()
                                    )
                                )
                        ) {
                            Column(
                                modifier = GlanceModifier.padding(
                                    vertical = 8.dp,
                                    horizontal = 4.dp
                                )
                                    .cornerRadius(16.dp).background(GlanceTheme.colors.surface)
                            ) {
                                Text(
                                    formatDate(mealDay.date),
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
                                        modifier = GlanceModifier.background(
                                            if (meal.selected) GlanceTheme.colors.tertiaryContainer else GlanceTheme.colors.surface
                                        ).padding(horizontal = 8.dp, vertical = 4.dp)
                                            .cornerRadius(12.dp).fillMaxWidth()
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
                item { Spacer(GlanceModifier.size(8.dp)) }
            }
        }
    }
}