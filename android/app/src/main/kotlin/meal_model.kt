import androidx.annotation.Keep
import com.google.gson.annotations.SerializedName

@Keep
data class Meal(
    @SerializedName("type")val type: String,
    @SerializedName("name")val name: String,
    @SerializedName("selected")val selected: Boolean,
)

data class MealDay(
    val date: String,
    val meals: List<Meal>
)