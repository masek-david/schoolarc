package com.example.myapp.glance

import HomeWidgetGlanceState
import HomeWidgetGlanceStateDefinition
import Meal
import MealDay
import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.padding
import androidx.glance.state.GlanceStateDefinition
import androidx.glance.text.Text
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

class StravaWidget : GlanceAppWidget() {

    override val stateDefinition: GlanceStateDefinition<*>
        get() = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            GlanceContent(context, currentState())
        }
    }

    @Composable
    private fun GlanceContent(context: Context, currentState: HomeWidgetGlanceState) {
        val data = currentState.preferences

        val meals : MutableList<MealDay> = mutableListOf()
        val json = data.getString("meals", null)

        val type = object : TypeToken<Map<String, List<Meal>>>() {}.type
        if(json != null){
            val map: Map<String, List<Meal>> = Gson().fromJson(json, type)

            map.forEach { (key, value) ->
                meals.add(MealDay(key, value))
            }
        }

        val prefs = currentState.preferences
        val counter = prefs.getInt("counter", 0)
        Box(modifier = GlanceModifier.background(Color.White).padding(16.dp)) {
            Column() {
                Text(
                    counter.toString()
                )
            }
        }
    }
}