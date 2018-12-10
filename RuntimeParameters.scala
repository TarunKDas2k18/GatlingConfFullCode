package simulations

import baseConfig.BaseSimulation
import io.gatling.core.Predef._
import io.gatling.core.structure.ChainBuilder
import io.gatling.http.Predef._

import scala.concurrent.duration.DurationInt

class RuntimeParameters extends BaseSimulation {


  // method that will get a property or default
  private def getProperty(propertyName: String, defaultValue: String) = {
    Option(System.getenv(propertyName))
      .orElse(Option(System.getProperty(propertyName)))
      .getOrElse(defaultValue)
  }

  // now specify the properties
  def userCount: Int = getProperty("USERS", "5").toInt
  def rampDuration: Int = getProperty("RAMP_DURATION", "10").toInt
  def testDuration: Int = getProperty("DURATION", "60").toInt

  // print out the properties at the start of the test
  before {
    println(s"Running test with ${userCount} users")
    println(s"Ramping users over ${rampDuration} seconds")
    println(s"Total Test duration: ${testDuration} seconds")
  }

  // add in test step(s)
  def getSingleEvent() :ChainBuilder = {
   repeat(times = 10) {

      exec(http("Get Event Reservation ")
        .get("event-reservations-service/Events/Search?lat=47.4797&lng=-122.2079&maxMeters=32187")
        .check(status.is(200)) // check for a specific status
        .check(jsonPath(path = "$.results[:1].name").saveAs(key = "name"))) // check for a specific status
        .exec { session => println(session); session } // this will give some high level data, but not that interesting as we don't have any variables!

    }
  }

  // add a scenario
  val scn = scenario("Event Reservation Service Search Event")
    .forever() { // add in the forever() method - users now loop forever
      exec(getSingleEvent())
    }

  // setup the load profile
  // example command line: ./gradlew gatlingRun-simulations.RuntimeParameters -DUSERS=10 -DRAMP_DURATION=5 -DDURATION=30
  setUp(
    scn.inject(
      nothingFor(5 seconds),
      rampUsers(userCount) over (rampDuration seconds))
  )
    .protocols(httpConf)
    .maxDuration(testDuration seconds)
}
