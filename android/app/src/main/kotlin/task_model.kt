import androidx.annotation.Keep
import com.google.gson.annotations.SerializedName

@Keep
data class Task(
    @SerializedName("isHomework") val isHomework:Boolean,
    @SerializedName("id") val id:String,
    @SerializedName("text") val text : String,
    @SerializedName("subject") val subject : String,
    @SerializedName("date") val date : Int,
    @SerializedName("isCompleted") var isCompleted : Boolean,
    @SerializedName("priority") val priority : Int,
    @SerializedName("hasDescription") val hasDescription : Boolean,
)