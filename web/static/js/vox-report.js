import React, { Component } from 'react'
import { render } from 'react-dom'
import Modal from 'antd/lib/modal'
import Button from 'antd/lib/button'
import FileSaver from 'file-saver'
import socket from './socket'
import 'phoenix_html'

class VoxReport extends Component {
  state = {
    channel: null,
    status: 'idle', // idle -> loading -> done
    received: 0
  }

  blob = ''

  componentWillMount() {
    this.state.channel = socket.channel('vox-report')

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

  mainButtonClick = () => {
    if (this.state.status == 'idle') {
      this.setState({ status: 'loading' })
      this.startDownload()
    }
  }

  startDownload = () => {
    this.state.channel.push('download')
    this.state.channel.on('row', ({ row }) => {
      this.blob = this.blob + row + '\n'
      this.setState({
        received: this.state.received + 1
      })
    })

    this.state.channel.on('done', () => {
      const blob = new Blob([this.blob], {type: "text/plain;charset=utf-8"})
      FileSaver.saveAs(blob, `vox-report-${new Date().toISOString()}.csv`)
      this.setState({status: 'done'})
    })
  }

  render() {
    const { status, received } = this.state

    return (
      <Modal
        visible={true}
        title="Download Vox Report"
        footer={[
          <Button
            key="main"
            type="primary"
            size="large"
            onClick={this.mainButtonClick}
            loading={status == 'loading'}
            disabled={status == 'done'}
          >
            {this.getButtonText()}
          </Button>
        ]}
      >
        Click the button to download your report as a .csv

        <br/>

        {status == 'loading' && (
          <strong> {`Recieved ${received} rows`}</strong>
        )}
      </Modal>
    )
  }

  getButtonText = () =>
    ({
      idle: 'Download',
      loading: 'Loading',
      done: 'Done'
    }[this.state.status])
}

render(<VoxReport />, document.getElementById('vox-report-app'))
