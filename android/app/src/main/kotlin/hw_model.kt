import androidx.annotation.Keep
import com.google.gson.annotations.SerializedName

@Keep
data class Homework(
    @SerializedName("type") val type: String,
    @SerializedName("dbIndex") val dbIndex:Int,
    @SerializedName("text") val text : String,
    @SerializedName("subject") val subject : String,
    @SerializedName("deadline") val deadline : String,
    @SerializedName("isCompleted") val isCompleted : Boolean,
    @SerializedName("priority") val priority : Int,
    @SerializedName("hasDescription") val description : Boolean,
)