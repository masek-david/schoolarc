import androidx.annotation.Keep
import com.google.gson.annotations.SerializedName

@Keep
data class Homework(
    @SerializedName("id") val id:String,
    @SerializedName("text") val text : String,
    @SerializedName("subject") val subject : String,
    @SerializedName("deadline") val deadline : String,
    @SerializedName("isCompleted") val isCompleted : Boolean,
    @SerializedName("priority") val priority : Int,
    @SerializedName("hasDescription") val description : Boolean,
)