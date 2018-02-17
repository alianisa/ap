package im.actor.server.push.google

final case class GooglePushMessage(
  to:           String,
  priority:String = "high",
  collapse_key: Option[String],
  notification: Option[Map[String, String]] = Some(
    Map()
  ),
  data: Option[Map[String, String]],
  time_to_live: Option[Int]
)
