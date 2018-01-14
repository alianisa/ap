package im.actor.server.grouppre.http

import akka.actor.ActorSystem
import akka.http.scaladsl.model.StatusCodes.{ OK}
import akka.http.scaladsl.server.Directives._
import akka.http.scaladsl.server.Route
import de.heikoseeberger.akkahttpcirce.CirceSupport
import im.actor.server.api.http.HttpHandler
import im.actor.server.api.http.json.JsonEncoders
import im.actor.server.grouppre.GroupPreExtension

private[grouppre] final class GroupPreHttpHandler()(implicit system: ActorSystem) extends HttpHandler
  with CirceSupport
  with JsonEncoders {

  private val groupPreExt = GroupPreExtension(system)

  override def routes: Route =
    defaultVersion {
      path("grouppre" / "reset" ) {
        get {
          groupPreExt.resetGroupPre()
          complete(OK)
        }
      }
    }
}