/***
 * Excerpted from "Pragmatic Scala",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/vsscala2 for more book information.
***/
import akka.actor._
import akka.routing._
import java.io._

class FilesCounter extends Actor {
  val start = System.nanoTime
  var filesCount = 0L
  var pending = 0

  val fileExploreres = 
    context.actorOf(RoundRobinPool(100).props(Props[FileExplorer]))

  def receive = {
    case fileName : String =>
      pending = pending + 1
      fileExploreres ! fileName
      
    case count : Int =>
      filesCount = filesCount + count
      pending = pending - 1
      
      if(pending == 0) {
        val end = System.nanoTime
        println(s"Files count: $filesCount")
        println(s"Time taken: ${(end - start)/1.0e9} seconds")
        context.system.shutdown()
      }
  }
}