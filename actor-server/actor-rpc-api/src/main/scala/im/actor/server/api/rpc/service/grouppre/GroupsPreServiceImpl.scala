package im.actor.server.api.rpc.service.grouppre

import akka.actor.ActorSystem
import im.actor.api.rpc.grouppre.{ApiGroupPre, GrouppreService, ResponseLoadGroupPre, ResponseLoadGroupsPre}
import im.actor.api.rpc.misc.ResponseSeq
import im.actor.api.rpc.{ClientData, _}
import im.actor.server.grouppre.GroupPreExtension

import scala.concurrent.{ExecutionContext, Future}

/**
 * Created by 98379720172 on 16/11/16.
 */
final class GroupsPreServiceImpl()(implicit actorSystem: ActorSystem) extends GrouppreService {

  case object NoSeqStateDate extends RuntimeException("No SeqStateDate in response from group found")
  case object NoGroupPre extends RuntimeException("No GroupPre in response from group found")

  override implicit val ec: ExecutionContext = actorSystem.dispatcher

  private val groupPreExt = GroupPreExtension(actorSystem)

  /** Carrega os grupos pre definidos */
  override protected def doHandleLoadGroupsPre(idGrupoPai: Option[Int], clientData: ClientData):
    Future[HandlerResult[ResponseLoadGroupsPre]] =
    authorized(clientData) { implicit client ⇒
      for {
        gruposPre <- groupPreExt.loadGroupsPre(client.userId, idGrupoPai)
        gruposApi = gruposPre map(gp =>  ApiGroupPre(groupId = gp.groupId,
          hasChildrem = gp.possuiFilhos,
          acessHash = gp.acessHash,
          order = gp.ordem,
          parentId = Option(gp.idPai)))
      } yield (Ok(ResponseLoadGroupsPre(groups = gruposApi.toIndexedSeq)))
    }

  /** LoadGroupPre */
  override protected def doHandleLoadGroupPre(groupPreId: Int, clientData: ClientData):
  Future[HandlerResult[ResponseLoadGroupPre]] =
    authorized(clientData) { implicit client ⇒
      for{
        grupoPre <- groupPreExt.loadGroupPre( client.userId, groupPreId)
        grupoApi = grupoPre map(gp =>  ApiGroupPre(groupId = gp.groupId,
          hasChildrem = gp.possuiFilhos,
          acessHash = gp.acessHash,
          order = gp.ordem,
          parentId = Option(gp.idPai)))
      }yield Ok(ResponseLoadGroupPre(grupoApi.get))
    }

  /** Change group parent */
  override protected def doHandleChangeGroupParent(groupId: Int, parentId: Int, clientData: ClientData) :
  Future[HandlerResult[ResponseSeq]] = {
    authorized(clientData) { implicit client ⇒
      for {
        ack <- groupPreExt.changeParent(groupId, parentId, client.userId, client.authId)
        seqState = ack.seqState.getOrElse(throw NoSeqStateDate)
      }yield(Ok(ResponseSeq(seqState.seq, seqState.state.toByteArray)))
    }
  }

  /** Create a new groupPre */
  override protected def doHandleChangeGroupPre(groupId: Int, isGroupPre: Boolean, clientData: ClientData):
  Future[HandlerResult[ResponseSeq]] =
      authorized(clientData) { implicit client ⇒
        if(isGroupPre){
          for{
            ack <- groupPreExt.create(groupId, client.userId, client.authId)
            seqState = ack.seqState.getOrElse(throw NoSeqStateDate)
          }yield(Ok(ResponseSeq(seqState.seq, seqState.state.toByteArray)))
        }else{
          for{
            ack <-  groupPreExt.remove(groupId, client.userId, client.authId)
            seqState = ack.seqState.getOrElse(throw NoSeqStateDate)
          }yield(Ok(ResponseSeq(seqState.seq, seqState.state.toByteArray)))
        }
    }

  /** Change group order */
  override protected def doHandleChangeOrder(fromGroupId: Int, toGroupId: Int, clientData: ClientData):
  Future[HandlerResult[ResponseSeq]] =
    authorized(clientData) { implicit client ⇒
      for{
        ack <- groupPreExt.changeOrder(fromGroupId, toGroupId, client.userId, client.authId)
        seqState = ack.seqState.getOrElse(throw NoSeqStateDate)
      }yield(Ok(ResponseSeq(seqState.seq, seqState.state.toByteArray)))
    }


}
