defmodule Londibot.Commands.Help do
  def description(:subscribe) do
    """
    *COMMAND*
    `londibot subscribe [lines]`

    *DESCRIPTION*
    Creates a subscription to said lines so that every time that any kind of disruption \
    happens in the TFL line, it's sent via message. This includes all changes to/from delays, \
    line closures, etc. except routinary changes like nightly closure and daily opening.

    *OPTIONS*
    Within the `[lines]` placeholder you may add any of the below options, \
    separated by a comma:

    _circle, district, dlr, hammersmith & city, london overground, metropolitan, \
    waterloo & city, bakerloo, central, jubilee, northern, picadilly, victoria, \
    tfl rail, tram_

    *EXAMPLES*
    londibot subscribe _dlr_
    londibot subscribe _victoria, metropolitan_

    *SEE ALSO*
    `londibot unsubscribe`
    `londibot subscriptions`
    """
  end

  def description(:unsubscribe) do
    """
    *COMMAND*
    `londibot unsubscribe [lines]`

    *DESCRIPTION*
    Deletes subcriptions to said lines, so notifications will no longer be sent.

    *OPTIONS*
    Within the `[lines]` placeholder you may add any of the below options, \
    separated by a comma:

    _circle, district, dlr, hammersmith & city, london overground, metropolitan, \
    waterloo & city, bakerloo, central, jubilee, northern, picadilly, victoria, \
    tfl rail, tram_

    *EXAMPLES*
    londibot unsubscribe _dlr_
    londibot unsubscribe _victoria, metropolitan_

    *SEE ALSO*
    `londibot subscribe`
    `londibot subscriptions`
    """
  end

  def description(:subscriptions) do
    """
    *COMMAND*
    `londibot subscriptions`

    *DESCRIPTION*
    Lists all the existing subscriptions

    *OPTIONS*
    This command doesn't accept any options

    *EXAMPLES*
    londibot subscriptions

    *SEE ALSO*
    `londibot subscribe`
    `londibot unsubscribe`
    """
  end

  def description(:status) do
    """
    *COMMAND*
    `londibot status`

    *DESCRIPTION*
    Lists a summary of the status of all the currently monitored TFL lines

    *OPTIONS*
    This command doesn't accept any options

    *EXAMPLES*
    londibot status

    *SEE ALSO*
    `londibot disruptions`
    `londibot subscribe`
    """
  end

  def description(:disruptions) do
    """
    *COMMAND*
    `londibot disruptions`

    *DESCRIPTION*
    Lists all the disruptions currently ongoing in the tube

    *OPTIONS*
    This command doesn't accept any options

    *EXAMPLES*
    londibot disruptions

    *SEE ALSO*
    `londibot status`
    `londibot subscribe`
    """
  end

  def description(_) do
    """
    *Londibot commands usage:*

    1. `londibot status`
      Display the current status of TFL lines

    2. `londibot disruptions`
      Display current disruptions throughout all lines

    3. `londibot subscribe [lines]`
      Subscribe to notifications on any disruptions for the lines

    4. `londibot unsubscribe [lines]`
      Unsubscribe to the notifications

    5. `londibot subscriptions`
      List all existing subscriptions

    6. `londibot help`
      Show this help

    Use `londibot help COMMAND` to see command help details.
    """
  end
end
