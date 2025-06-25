package cz.masci.schoolarc

import HomeWidgetGlanceWidgetReceiver

class HwWidgetReceiver : HomeWidgetGlanceWidgetReceiver<HwWidget>() {
    override val glanceAppWidget = HwWidget()
}