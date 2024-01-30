/*
 * Copyright 2020 Eike K. & Contributors
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

package docspell.notification.impl.context

import cats.effect._

import docspell.common._
import docspell.notification.api._
import docspell.notification.impl.AbstractEventContext

import doobie._
import io.circe.Encoder
import io.circe.syntax._
import yamusca.implicits._

final case class JobSubmittedCtx(event: Event.JobSubmitted, data: JobSubmittedCtx.Data)
    extends AbstractEventContext {

  val content = data.asJson

  val titleTemplate = Right(mustache"{{eventType}} (by *{{account.user}}*)")
  val bodyTemplate =
    Right(
      mustache"""{{#content}}_'{{subject}}'_ submitted by {{submitter}} {{/content}}"""
    )
}

object JobSubmittedCtx {

  type Factory = EventContext.Factory[ConnectionIO, Event.JobSubmitted]

  def apply: Factory =
    EventContext.pure(ev => JobSubmittedCtx(ev, Data(ev)))

  def sample[F[_]: Sync]: EventContext.Example[F, Event.JobSubmitted] =
    EventContext.example(ev => Sync[F].pure(JobSubmittedCtx(ev, Data(ev))))

  final case class Data(
      job: Ident,
      group: Ident,
      task: Ident,
      args: String,
      state: JobState,
      subject: String,
      submitter: Ident
  )
  object Data {
    implicit val jsonEncoder: Encoder[Data] =
      io.circe.generic.semiauto.deriveEncoder

    def apply(ev: Event.JobSubmitted): Data =
      Data(ev.jobId, ev.group, ev.task, ev.args, ev.state, ev.subject, ev.submitter)
  }

}
