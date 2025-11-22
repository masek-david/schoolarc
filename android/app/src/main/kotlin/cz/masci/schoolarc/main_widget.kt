package cz.masci.schoolarc

import HomeWidgetGlanceState
import HomeWidgetGlanceStateDefinition
import Task
import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
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
import androidx.core.net.toUri
import androidx.glance.Button
import androidx.glance.LocalContext
import androidx.glance.action.clickable
import androidx.glance.appwidget.action.ToggleableStateKey
import androidx.glance.preview.ExperimentalGlancePreviewApi
import androidx.glance.preview.Preview
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.materialkolor.blend.Blend
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.actionStartActivity
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.Locale

// Used for sending info to CompleteAction
val taskIdKey = ActionParameters.Key<String>("id")

class CompleteAction : ActionCallback {
    override suspend fun onAction(
        context: Context, glanceId: GlanceId, parameters: ActionParameters
    ) {
        val id = parameters[taskIdKey]
        val completed = parameters[ToggleableStateKey]
        val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
            context, "school://complete/?id=$id&complete=$completed".toUri()
        )
        backgroundIntent.send()
    }
}

class MainWidget : GlanceAppWidget() {
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

    @Composable
    fun getPriorityColor(index: Int): Color {
        val color = when (index) {
            3 -> Color(217, 82, 65).toArgb()
            2 -> Color(255, 152, 0).toArgb()
            1 -> Color(111, 173, 92).toArgb()
            else -> Color(83, 148, 236).toArgb()
        }

        return Color(
            Blend.harmonize(
                color, GlanceTheme.colors.widgetBackground.getColor(LocalContext.current).toArgb()
            )
        )
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

    @OptIn(ExperimentalGlancePreviewApi::class)
    @Preview(widthDp = 350, heightDp = 350)
    @Composable
    private fun GlanceContent(currentState: HomeWidgetGlanceState) {
        var allTasks: MutableMap<String, MutableList<Task>> = mutableMapOf()
        val isDebug = false
        val context = LocalContext.current

        if (isDebug) {
            allTasks = mutableMapOf(
                "20251101" to mutableListOf(
                    Task(
                        isHomework = true,
                        id = "1",
                        text = "Complete algebra worksheet",
                        subject = "Math",
                        date = 20251103,
                        isCompleted = false,
                        priority = 2,
                        hasDescription = true,
                    )
                ),
                "20251103" to mutableListOf(
                    Task(
                        isHomework = false,
                        id = "2",
                        text = "Chemistry test",
                        subject = "Chem",
                        date = 20251105,
                        isCompleted = false,
                        priority = 3,
                        hasDescription = true,
                    ),
                    Task(
                        isHomework = true,
                        id = "3",
                        text = "Write English essay draft",
                        subject = "Eng",
                        date = 20251104,
                        isCompleted = true,
                        priority = 1,
                        hasDescription = true,
                    ),
                ),
                "20251104" to mutableListOf(
                    Task(
                        isHomework = true,
                        id = "5",
                        text = "Finish biology lab report",
                        subject = "Biology",
                        date = 20251102,
                        isCompleted = true,
                        priority = 3,
                        hasDescription = true,
                    ), Task(
                        isHomework = true,
                        id = "2",
                        text = "Olympiáda",
                        subject = "Ma",
                        date = 20251130,
                        isCompleted = false,
                        priority = 1,
                        hasDescription = true
                    ), Task(
                        isHomework = true,
                        id = "3",
                        text = "Chemistry NMR assignment",
                        subject = "CHEM",
                        date = 20251130,
                        isCompleted = true,
                        priority = 0,
                        hasDescription = true
                    )
                ),
            )
        } else {
            val data = currentState.preferences

            val hwJson = data.getString("tasks", null)
            val locJson = data.getString("loc", null)

            val type = object : TypeToken<Map<String, List<Task>>>() {}.type
            if (hwJson != null) {
                allTasks = Gson().fromJson(hwJson, type)
            }

            if (locJson != null) {
                val loc = Gson().fromJson<Map<String, String>>(
                    locJson, object : TypeToken<Map<String, String>>() {}.type
                )
                today = loc["today"] ?: today
                tomorrow = loc["tomorrow"] ?: tomorrow
                locale = loc["locale"] ?: locale
                format = loc["format"] ?: format
                shortFormat = loc["shortFormat"] ?: shortFormat
            }
        }

        Box(
            GlanceModifier.fillMaxSize().background(GlanceTheme.colors.widgetBackground)
                .cornerRadius(24.dp)
        ) {
            LazyColumn {
                allTasks.entries.sortedBy { it.key }.forEach { (dateString, tasksForDate) ->
                    val date = dateFromPrimitiveDate(dateString.toInt())
                    if (!date.isBefore(LocalDate.now()))
                        item {
                            Row(
                                modifier = GlanceModifier.fillMaxWidth().clickable(
                                    actionStartActivity<MainActivity>(
                                        context, "schoolarc://".toUri()
                                    )
                                )
                            ) {
                                Text(
                                    formatDate(date), style = if (tasksForDate.isEmpty()) TextStyle(
                                        GlanceTheme.colors.onSurfaceVariant,
                                        16.sp,
                                    ) else TextStyle(
                                        GlanceTheme.colors.onSurface, 16.sp, FontWeight.Medium
                                    ), modifier = GlanceModifier.padding(
                                        start = 16.dp, end = 8.dp, top = 10.dp, bottom = 0.dp
                                    )
                                )
                            }
                        }
                    if (!date.isBefore(LocalDate.now()))
                        items(tasksForDate) { task ->
                            Box(
                                modifier = GlanceModifier.padding(
                                    top = 6.dp, start = 6.dp, end = 6.dp
                                )
                            ) {
                                Row(
                                    modifier = GlanceModifier.fillMaxWidth().padding(5.dp)
                                        .background(
                                            GlanceTheme.colors.surface.getColor(
                                                LocalContext.current
                                            ).copy(if (task.isCompleted) 0.5f else 1.0f)
                                        ).cornerRadius(if (task.isHomework) 12.dp else 100.dp)
                                        .clickable(
                                            actionStartActivity<MainActivity>(
                                                LocalContext.current,
                                                "schoolarc://view/?id=${task.id}&isHomework=${task.isHomework}".toUri()
                                            ),
                                        ), verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Box(
                                        contentAlignment = Alignment.Center,
                                        modifier = GlanceModifier.width(45.dp).height(45.dp)
                                            .let { base ->
                                                if (task.isHomework) {
                                                    base.background(GlanceTheme.colors.secondaryContainer)
                                                        .cornerRadius(7.dp)
                                                } else {
                                                    base.background(getPriorityColor(task.priority))
                                                        .cornerRadius(100.dp)
                                                }
                                            }

                                    ) {
                                        Text(
                                            task.subject, style = TextStyle(
                                                color = GlanceTheme.colors.onPrimaryContainer,
                                                textAlign = TextAlign.Center,
                                                fontWeight = FontWeight.Bold
                                            )
                                        )
                                    }
                                    Text(
                                        task.text,
                                        maxLines = 2,
                                        style = TextStyle(
                                            color = GlanceTheme.colors.onBackground,
                                            fontSize = 13.sp
                                        ),
                                        modifier = GlanceModifier.defaultWeight()
                                            .padding(horizontal = 6.dp)
                                    )
                                    if (task.isHomework) CheckBox(
                                        task.isCompleted,

                                        actionRunCallback<CompleteAction>(
                                            parameters = actionParametersOf(
                                                taskIdKey to task.id,
                                            )
                                        ), colors = CheckboxDefaults.colors(
                                            checkedColor = getPriorityColor(task.priority).copy(
                                                alpha = 0.6f
                                            ),
                                            uncheckedColor = getPriorityColor(task.priority)
                                        ), modifier = GlanceModifier.cornerRadius(32.dp)
                                    )
                                }
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
                "+",
                style = TextStyle(fontSize = 24.sp),
                onClick = actionStartActivity<MainActivity>(
                    LocalContext.current, "schoolarc://create".toUri()
                ),
                modifier = GlanceModifier.size(50.dp).padding(bottom = 2.dp, start = 1.dp)
            )
        }
    }
}

