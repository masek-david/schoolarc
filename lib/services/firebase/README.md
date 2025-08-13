# GROUPS

The id of each group is the same as the id of the user that created it.
This owner has access to the whole group. Under "u", the members are stored.
Each member can remove themselves from the group (set to null), or put themselves on the waitline (set to false).
If false, the user is waiting for confirmation - only the owner can only set false to true.

groups{
    "idOfOwner":{
        "n":"Group Name",       // public read
        "u":{                   // "u" doesnt contain the owner, his id is the name of the group
            "user1" : true,
            "user2" : true,
            "user3" : false     // waiting for approval
        }
    }
}

The fetched tasks are those have "sh" not null and the value (milisecondsSinceEpoch) is newer than now.
"sh" is set if isShared is true and is set to value of deadline/date, minus three days

How it is fetched
You get the group of user, get all its users 
For each user, find their shared subjects, exams, homework
Assign subjects to each exam and homework
For homeworks, mark each as uncompleted
done

When saving locally
Save as normally, but try to find subject with the same bakaId, or matching name
Save with the same id as owners, so you always know which ones you have imported