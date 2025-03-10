package com.example.myapp

import HomeWidgetGlanceWidgetReceiver

class HwWidgetReceiver : HomeWidgetGlanceWidgetReceiver<HwWidget>() {
    override val glanceAppWidget = HwWidget()
}