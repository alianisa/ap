package im.actor.server.file.local

import com.github.kxbmap.configs.syntax._
import com.typesafe.config.Config
import im.actor.config.ActorConfig

import scala.util.Try

case class LocalFileStorageConfig(location: String, maxFileSize: Int)

object LocalFileStorageConfig {
  def load(config: Config): Try[LocalFileStorageConfig] = {
    for {
      location ← config.get[Try[String]]("location")
      maxFileSize ← config.get[Try[Int]]("max-file-size")
    } yield LocalFileStorageConfig(location, maxFileSize)
  }

  def load: Try[LocalFileStorageConfig] =
    for {
      config ← Try(ActorConfig.load().getConfig("services.file-storage"))
      result ← load(config)
    } yield result
}
