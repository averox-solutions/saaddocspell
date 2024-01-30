/*
 * Copyright 2020 Eike K. & Contributors
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

package docspell.extract.ocr

import docspell.common.MimeType

object OcrType {

  val jpeg = MimeType.jpeg
  val png = MimeType.png
  val tiff = MimeType.tiff
  val pdf = MimeType.pdf

  val all = Set(jpeg, png, tiff, pdf)

  def unapply(mt: MimeType): Option[MimeType] =
    Some(mt).map(_.baseType).filter(all.contains)
}
