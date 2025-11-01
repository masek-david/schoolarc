package cz.masci.schoolarc

import java.time.LocalDate
import java.time.format.DateTimeFormatter

fun dateFromPrimitiveDate(primitiveDate: Int): LocalDate {
    return LocalDate.parse(
        primitiveDate.toString(), DateTimeFormatter.ofPattern("yyyyMMdd")
    )
}