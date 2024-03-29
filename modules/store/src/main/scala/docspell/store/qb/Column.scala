/*
 * Copyright 2020 Eike K. & Contributors
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

package docspell.store.qb

case class Column[A](name: String, table: TableDef) {
  def inTable(t: TableDef): Column[A] =
    copy(table = t)

  def cast[B]: Column[B] =
    this.asInstanceOf[Column[B]]

}

object Column {}
