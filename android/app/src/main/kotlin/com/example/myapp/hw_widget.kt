package com.example.myapp

import HomeWidgetGlanceState
import HomeWidgetGlanceStateDefinition
import Homework
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.ContextCompat.startActivity
import androidx.glance.BackgroundModifier
import androidx.glance.Button
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.LocalSize
import androidx.glance.action.Action
import androidx.glance.action.ActionParameters
import androidx.glance.action.action
import androidx.glance.action.actionParametersOf
import androidx.glance.action.clickable
import androidx.glance.appwidget.CheckBox
import androidx.glance.appwidget.CheckBoxColors
import androidx.glance.appwidget.CheckboxDefaults
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.lazy.LazyColumn
import androidx.glance.appwidget.lazy.items
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.layout.wrapContentSize
import androidx.glance.state.GlanceStateDefinition
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.actionStartActivity

public fun getPriorityColor(index: Int): Color {
    when (index) {
        3 -> return Color(217, 82, 65)
        2 -> return Color(255, 152, 0)
        1 -> return Color(111, 173, 92)
    }
    return Color(83, 148, 236)
}

class CompleteAction : ActionCallback {
    override suspend fun onAction(
        context: Context, glanceId: GlanceId, parameters: ActionParameters
    ) {
        val isCompleted =
            parameters.get<Boolean>(ActionParameters.Key("android.widget.extra.CHECKED"))
        val dbIndex = parameters[dbIndexKey]
        println("$dbIndex; completed: $isCompleted")

        val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
            context,
            Uri.parse("school://complete/?db=$dbIndex&complete=$isCompleted"),
        )
        backgroundIntent.send()
    }
}

val dbIndexKey = ActionParameters.Key<Int>("dbIndex")

class HwWidget : GlanceAppWidget() {

    override val sizeMode = SizeMode.Exact

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
        val size = LocalSize.current

        var hws: MutableList<Homework> = mutableListOf()
        val data = currentState.preferences

        val json = data.getString("hw", null)

        val type = object : TypeToken<List<Homework>>() {}.type
        if (json != null) {
            hws = Gson().fromJson(json, type)
        }

        if (hws.isEmpty()) {
            Box(
                modifier = GlanceModifier.background(GlanceTheme.colors.widgetBackground)
                    .fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    "No homeworks found", style = TextStyle(color = GlanceTheme.colors.onBackground)
                )
            }
            return
        }

        Box(
            modifier = GlanceModifier.background(GlanceTheme.colors.widgetBackground).fillMaxSize()
        ) {
            LazyColumn {
                items(hws) { hw ->
                    Box(
                        modifier = GlanceModifier.padding(horizontal = 6.dp).padding(top = 6.dp)
                    ) {
                        Row(
                            modifier = GlanceModifier.fillMaxWidth().padding(6.dp)
                                .background(GlanceTheme.colors.surface).cornerRadius(12.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Box(
                                contentAlignment = Alignment.Center,
                                modifier = GlanceModifier.background(GlanceTheme.colors.primaryContainer)
                                    .width(45.dp).height(45.dp).cornerRadius(6.dp)
                            ) {
                                Text(
                                    hw.subject, style = TextStyle(
                                        color = GlanceTheme.colors.onPrimaryContainer,
                                        textAlign = TextAlign.Center,
                                        fontWeight = FontWeight.Bold
                                    )
                                )
                            }
                            Text(
                                hw.text,
                                maxLines = 2,
                                style = TextStyle(color = GlanceTheme.colors.onBackground),
                                modifier = GlanceModifier.defaultWeight().padding(4.dp)
                            )
                            if (size.width > 260.dp) Text(
                                hw.deadline, style = TextStyle(
                                    color = GlanceTheme.colors.onBackground, fontSize = 12.sp
                                ), modifier = GlanceModifier.padding(4.dp)
                            )
                            CheckBox(
                                hw.isCompleted,
                                actionRunCallback<CompleteAction>(
                                    parameters = actionParametersOf(dbIndexKey to hw.dbIndex)
                                ),
                                colors = CheckboxDefaults.colors(
                                    checkedColor = getPriorityColor(hw.priority),
                                    uncheckedColor = getPriorityColor(hw.priority)
                                ),
                                modifier = GlanceModifier.cornerRadius(16.dp)
                            )
                        }
                    }
                }
                item {
                    Spacer(modifier = GlanceModifier.size(62.dp))
                }
            }
//            Box(
//                modifier = GlanceModifier.padding(8.dp).fillMaxSize(),
//                contentAlignment = Alignment.BottomEnd
//            ) {
//                Button(
//                    "+",
//                    style = TextStyle(fontSize = 24.sp),
//                    onClick = actionStartActivity<MainActivity>(
//                        context,
//                        Uri.parse("school://create")
//                    ),
//                    modifier = GlanceModifier.size(50.dp).padding(bottom = 2.dp, start = 1.dp)
//                )
//            }
        }
    }
}
