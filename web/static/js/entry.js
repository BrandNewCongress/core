import React, { Component } from 'react'
import { render } from 'react-dom'
import Row from './entry/row'
import Input from 'antd/lib/input'
import Select from 'antd/lib/select'
import Button from 'antd/lib/button'
import socket from './socket'
import 'phoenix_html'

const { Option } = Select

const initialState = {
  channel: null,
  rows: [],
  contactMethod: undefined,
  campaign: undefined
}

class Entry extends Component {
  state = Object.assign({}, initialState)
  counter = 0

  componentWillMount() {
    this.state.channel = socket.channel('entry')

    this.state.channel
      .join()
      .receive('ok', msg => {
        console.log(`Connected with ${JSON.stringify(msg)}`)
        console.log(msg)
      })
      .receive('error', msg => {
        console.log(`Could not connect with ${JSON.stringify(msg)}`)
        console.log(msg)
      })
  }

  setContactMethod = value => {
    this.state.contactMethod = value
    this.checkReadyForRows()
  }

  setCampaign = value => {
    this.state.campaign = value
    this.checkReadyForRows()
  }

  resetState = () => this.setState(initialState)

  checkReadyForRows = () => {
    if (
      this.state.contactMethod !== undefined &&
      this.state.campaign !== undefined &&
      this.state.rows.length == 0
    )
      this.addRow()
    else this.forceUpdate()
  }

  addRow = () => {
    this.counter = this.counter + 1
    this.setState({
      rows: this.state.rows.concat([this.counter])
    })
  }

  render() {
    const { rows, campaign, contactMethod, channel } = this.state

    return (
      <div>
        <div className="entry-header">
          <h1> BNC Data Entnry </h1>

          <div>
            <div className="field">
              <label> Contact Type </label>
              <br />
              <Select
                name="contact-method"
                onSelect={this.setContactMethod}
              >
                <Option value="door_knock"> Canvassing </Option>
                <Option value="phone_call"> Phone Calls </Option>
                <Option value="event_rsvp"> Event RSVPs </Option>
              </Select>
            </div>

            <div className="field">
              <label> Campaign </label>
              <br />
              <Select
                name="campaign"
                onSelect={this.setCampaign}
              >
                {window.campaigns.map(({ district, title, slug }) =>
                  <Option value={slug} key={slug}>
                    {district
                      ? `${district} – ${title}`
                      : title
                    }
                  </Option>
                )}
              </Select>
            </div>

            <Button
              style={{ marginLeft: 30 }}
              type="danger"
              onClick={this.resetState}
            >
              Clear All
            </Button>
          </div>
        </div>

        {rows.map(r =>
          <Row
            key={r}
            counter={r}
            campaign={campaign}
            contactMethod={contactMethod}
            channel={channel}
            addRow={this.addRow}
          />
        )}
      </div>
    )
  }
}

render(<Entry />, document.getElementById('entry-app'))
