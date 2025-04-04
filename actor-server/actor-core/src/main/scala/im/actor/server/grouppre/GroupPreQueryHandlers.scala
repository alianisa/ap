package im.actor.server.grouppre

import im.actor.server.GroupPre
import im.actor.server.GroupPreQueries.{GetGroupPreResponse, GetGroupsPreResponse}
import im.actor.server.persist.grouppre.PublicGroupRepo

import scala.concurrent.Future

/**
  * Created by diego on 28/03/17.
  */
trait GroupPreQueryHandlers {
  self: GroupPreProcessor =>

  protected def loadGroupsPre(idPai: Int): Future[GetGroupsPreResponse]= {
    val action = (for{
      groupsPre <- PublicGroupRepo.findByIdPai(idPai)

      gruposApi = groupsPre map(gp => GroupPre(groupId = gp.id,
        tipo = gp.typ,
        ordem = gp.position,
        possuiFilhos = gp.hasChildrem,
        idPai = gp.parentId,
        acessHash = gp.accessHash))

    } yield GetGroupsPreResponse(gruposApi.toIndexedSeq))

    db.run(action)
  }

  protected def loadGroupPre(groupId: Int): Future[GetGroupPreResponse]= {
    val action = (for{
      groupsPre <- PublicGroupRepo.findById(groupId)

      grupoApi = groupsPre map(gp => GroupPre(groupId = gp.id,
        tipo = gp.typ,
        ordem = gp.position,
        possuiFilhos = gp.hasChildrem,
        idPai = gp.parentId,
        acessHash = gp.accessHash))

    } yield GetGroupPreResponse(grupoApi))

    db.run(action)
  }

}
