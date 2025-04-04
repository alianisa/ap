package im.actor.server.dialog

import akka.actor.ActorSystem
import akka.http.scaladsl.util.FastFuture
import im.actor.api.rpc.messaging._
import im.actor.server.group.GroupExtension
import im.actor.server.model.{HistoryMessage, MessageType, Peer, PeerType}
import im.actor.server.persist.HistoryMessageRepo
import org.joda.time.DateTime
import slick.dbio.DBIO

import scala.concurrent.{ExecutionContext, Future}
import scala.util.control.NoStackTrace

object HistoryUtils {

  // User for writing history in public groups
  val SharedUserId = 0

  private[dialog] def writeHistoryMessage(
    fromPeer:             Peer,
    toPeer:               Peer,
    dateMillis:           Long,
    randomId:             Long,
    messageContentHeader: Int,
    messageContentData:   Array[Byte],
    messageType: Option[MessageType]
  )(implicit system: ActorSystem): DBIO[Unit] = {
    import system.dispatcher
    requirePrivatePeer(fromPeer)
    // requireDifferentPeers(fromPeer, toPeer)

    val date = new DateTime(dateMillis)

    if (toPeer.typ == PeerType.Private) {
      val outMessage = HistoryMessage(
        userId = fromPeer.id,
        peer = toPeer,
        date = date,
        senderUserId = fromPeer.id,
        randomId = randomId,
        messageContentHeader = messageContentHeader,
        messageContentData = messageContentData,
        deletedAt = None,
        messageType = messageType
      )

      val messages =
        if (fromPeer != toPeer) {
          Seq(
            outMessage,
            outMessage.copy(userId = toPeer.id, peer = fromPeer)
          )
        } else {
          Seq(outMessage)
        }

      for {
        _ ← HistoryMessageRepo.create(messages)
      } yield ()
    } else if (toPeer.typ == PeerType.Group) {
      for {
        isHistoryShared ← DBIO.from(GroupExtension(system).isHistoryShared(toPeer.id))
        _ ← if (isHistoryShared) {
          val historyMessage = HistoryMessage(SharedUserId, toPeer, date, fromPeer.id, randomId, messageContentHeader, messageContentData, None, messageType)
          HistoryMessageRepo.create(historyMessage) map (_ ⇒ ())
        } else {
          DBIO.from(GroupExtension(system).getMemberIds(toPeer.id)) map (_._1) flatMap { groupUserIds ⇒
            val historyMessages = groupUserIds.map { groupUserId ⇒
              HistoryMessage(groupUserId, toPeer, date, fromPeer.id, randomId, messageContentHeader, messageContentData, None, messageType)
            }
            HistoryMessageRepo.create(historyMessages) map (_ ⇒ ())
          }
        }
      } yield ()
    } else {
      DBIO.failed(new Exception("PeerType is not supported") with NoStackTrace)
    }
  }

  private[dialog] def writeHistoryMessageSelf(
    userId:               Int,
    toPeer:               Peer,
    senderUserId:         Int,
    dateMillis:           Long,
    randomId:             Long,
    messageContentHeader: Int,
    messageContentData:   Array[Byte],
    messageType: Option[MessageType]
  )(implicit ec: ExecutionContext): DBIO[Unit] = {
    for {
      _ ← HistoryMessageRepo.create(HistoryMessage(
        userId = userId,
        peer = toPeer,
        date = new DateTime(dateMillis),
        senderUserId = senderUserId,
        randomId = randomId,
        messageContentHeader = messageContentHeader,
        messageContentData = messageContentData,
        deletedAt = None,
        messageType = messageType
      ))
    } yield ()
  }

  def getHistoryOwner(peer: Peer, clientUserId: Int)(implicit system: ActorSystem): Future[Int] = {
    import system.dispatcher
    peer.typ match {
      case PeerType.Private ⇒ FastFuture.successful(clientUserId)
      case PeerType.Group ⇒
        for {
          isHistoryShared ← GroupExtension(system).isHistoryShared(peer.id)
        } yield if (isHistoryShared) SharedUserId else clientUserId
      case _ ⇒ throw new RuntimeException(s"Unknown peer type ${peer.typ}")
    }
  }

  def isSharedUser(userId: Int): Boolean = userId == SharedUserId

  private def requirePrivatePeer(peer: Peer) = {
    if (peer.typ != PeerType.Private)
      throw new RuntimeException("sender should be Private peer")
  }

  def getMessageType(apiMessage: ApiMessage):Option[MessageType] = {
    apiMessage match {
      case mess :ApiDocumentMessage => {
        mess.ext match {
          case Some(_:ApiDocumentExVideo) =>{
            Some(MessageType.Video)
          }
          case Some(_: ApiDocumentExPhoto) => {
            Some(MessageType.Photo)
          }
          case Some(_: ApiDocumentExAnimation) => {
            Some(MessageType.Animation)
          }
          case Some(_: ApiDocumentExAnimationVid) => {
            Some(MessageType.Animation)
          }
          case Some(_: ApiDocumentExVoice) => {
            Some(MessageType.Voice)
          }
          case None => {
            Some(MessageType.Document)
          }
        }
      }
      case _ => {
        Some(MessageType.Undefined)
      }
    }
  }
}
