package cz.masci.schoolarc

import HomeWidgetGlanceState
import HomeWidgetGlanceStateDefinition
import Task
import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalInspectionMode
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.LocalSize
import androidx.glance.action.ActionParameters
import androidx.glance.action.actionParametersOf
import androidx.glance.appwidget.CheckBox
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
import androidx.glance.state.GlanceStateDefinition
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import androidx.core.net.toUri
import androidx.glance.Button
import androidx.glance.preview.ExperimentalGlancePreviewApi
import androidx.glance.preview.Preview
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.time.LocalDate
import java.time.format.DateTimeFormatter

fun getPriorityColor(index: Int): Color {
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
        val dbIndex = parameters[idKey]
        println("$dbIndex; completed: $isCompleted")

        val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
            context,
            "school://complete/?db=$dbIndex&complete=$isCompleted".toUri(),
        )
        backgroundIntent.send()
    }
}

val idKey = ActionParameters.Key<String>("id")

class HwWidget : GlanceAppWidget() {
    override val sizeMode = SizeMode.Exact

    override val stateDefinition: GlanceStateDefinition<*>
        get() = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            GlanceTheme {
                GlanceContent(currentState())
            }
        }
    }

    private fun getDateText(primitiveDate: Int, format: String, shortFormat: String): String {
        val date = LocalDate.parse(
            primitiveDate.toString(), DateTimeFormatter.ofPattern("yyyyMMdd")
        )

        val finalFormat = if (LocalDate.now().year == date.year) shortFormat else format

        return date.format(DateTimeFormatter.ofPattern(finalFormat))
    }

    @OptIn(ExperimentalGlancePreviewApi::class)
    @Preview(widthDp = 350, heightDp = 250)
    @Composable
    private fun GlanceContent(currentState: HomeWidgetGlanceState) {
        val size = LocalSize.current
        var tasks: MutableList<Task> = mutableListOf()
        var format = ""
        var shortFormat = ""

        if (true) {
            format = "dd. MMM yyyy"
            shortFormat = "dd. MMM"
            tasks = mutableListOf(
                Task(
                    isHomework = false,
                    id = "1",
                    text = "Writing watching movies with William and i have to write here something",
                    subject = "Aj",
                    date = 20250929,
                    isCompleted = false,
                    priority = 2,
                    hasDescription = true
                ), Task(
                    isHomework = true,
                    id = "2",
                    text = "Olympiáda",
                    subject = "Ma",
                    date = 20261029,
                    isCompleted = false,
                    priority = 1,
                    hasDescription = true
                ), Task(
                    isHomework = true,
                    id = "3",
                    text = "Chemistry NMR assignment",
                    subject = "CHEM",
                    date = 20251029,
                    isCompleted = true,
                    priority = 0,
                    hasDescription = true
                )
            )
        } else {
            val data = currentState.preferences

            val hwJson = data.getString("hw", null)
            val locJson = data.getString("loc", null)

            val type = object : TypeToken<List<Task>>() {}.type
            if (hwJson != null) {
                tasks = Gson().fromJson(hwJson, type)
            }
            if (locJson != null) {
                val loc = Gson().fromJson(locJson, String::class.java)
            }
        }

        Box(
            modifier = GlanceModifier.background(GlanceTheme.colors.widgetBackground).fillMaxSize()
        ) {
            if (tasks.isEmpty()) {

                Box(
                    modifier = GlanceModifier.background(GlanceTheme.colors.widgetBackground)
                        .fillMaxSize(), contentAlignment = Alignment.Center
                ) {
                    Text(
                        "No homeworks found",
                        style = TextStyle(color = GlanceTheme.colors.onBackground)
                    )
                }
            } else {
                LazyColumn {
                    items(tasks) { hw ->
                        Box(
                            modifier = GlanceModifier.padding(
                                start = 6.dp, end = 6.dp, top = 6.dp
                            )
                        ) {
                            Row(
                                modifier = GlanceModifier.fillMaxWidth().padding(5.dp)
                                    .background(GlanceTheme.colors.surface)
                                    .cornerRadius(if (hw.isHomework) 12.dp else 100.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Box(
                                    contentAlignment = Alignment.Center,
                                    modifier = GlanceModifier
                                        .width(45.dp)
                                        .height(45.dp)
                                        .let { base ->
                                            if (hw.isHomework) {
                                                base
                                                    .background(GlanceTheme.colors.secondaryContainer)
                                                    .cornerRadius(7.dp)
                                            } else {
                                                base
                                                    .background(getPriorityColor(hw.priority))
                                                    .cornerRadius(100.dp)
                                            }
                                        }

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
                                    style = TextStyle(
                                        color = GlanceTheme.colors.onBackground, fontSize = 13.sp
                                    ),
                                    modifier = GlanceModifier.defaultWeight()
                                        .padding(horizontal = 6.dp)
                                )
                                if (size.width > 260.dp) Text(
                                    getDateText(hw.date, format, shortFormat), style = TextStyle(
                                        color = GlanceTheme.colors.onBackground, fontSize = 12.sp
                                    ), modifier = GlanceModifier.padding(4.dp)
                                )
                                if (hw.isHomework)
                                    CheckBox(
                                        hw.isCompleted, actionRunCallback<CompleteAction>(
                                            parameters = actionParametersOf(idKey to hw.id)
                                        ), colors = CheckboxDefaults.colors(
                                            checkedColor = getPriorityColor(hw.priority),
                                            uncheckedColor = getPriorityColor(hw.priority)
                                        ), modifier = GlanceModifier.cornerRadius(32.dp)
                                    )
                            }
                        }
                    }
                    item {
                        Spacer(modifier = GlanceModifier.size(62.dp))
                    }
                }
            }
            Box(
                modifier = GlanceModifier.padding(8.dp).fillMaxSize(),
                contentAlignment = Alignment.BottomEnd
            ) {
                Button(
                    "+", style = TextStyle(fontSize = 24.sp), onClick = {},
//                    onClick = actionStartActivity<MainActivity>(
//                        context,
//                        "school://create".toUri()
//                    ),
                    modifier = GlanceModifier.size(50.dp).padding(bottom = 2.dp, start = 1.dp)
                )
            }
        }
    }
}
