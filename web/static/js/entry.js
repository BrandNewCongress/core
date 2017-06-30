import React, { Component } from 'react'
import { render } from 'react-dom'
import Row from './entry/row'
import socket from './socket'
import 'phoenix_html'

const print = s => {
  console.log(s)
  return s
}

class Entry extends Component {
  state = {
    channel: null,
    rows: [],
    contactMethod: undefined,
    campaign: undefined
  }

  componentWillMount() {
    this.state.channel = socket.channel('entry')
  }

  setContactMethod = ev => {
    this.setState({ contactMethod: ev.target.value })
    this.checkReadyForRows()
  }

  setCampaign = ev => {
    this.setState({ campaign: ev.target.value })
    this.checkReadyForRows()
  }

  checkReadyForRows = () =>
    this.state.contactMethod !== undefined &&
    this.state.campaign !== undefined &&
    this.state.rows.length == 0 &&
    this.addRow()

  addRow = () =>
    this.setState({
      rows: this.state.rows.concat([Math.random()])
    })

  render() {
    const { rows, campaign, contactMethod, channel } = this.state

    return (
      <div>
        <div className='entry-header'>
          <h1> BNC Data Entnry </h1>

          <div>
            <div className="field">
              <label for="contact-method"> Contact Type </label>
              <br />
              <select name="contact-method" onChange={this.setContactMethod}>
                <option value={undefined}></option>
                <option value="door_knock"> Canvas </option>
                <option value="phone_call"> Phone Call </option>
              </select>
            </div>

            <div className="field">
              <label for="campaign"> Campaign </label>
              <br />
              <select name="campaign" onChange={this.setCampaign}>
                <option value={undefined}></option>
                {window.campaigns.map(({ title, slug }) =>
                  <option value={slug}>{title}</option>
                )}
              </select>
            </div>
          </div>
        </div>

        {rows.map(r =>
          <Row
            key={r}
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
