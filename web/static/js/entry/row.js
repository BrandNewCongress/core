import React, { Component } from 'react'
import Input from 'antd/lib/input'
import Select from 'antd/lib/select'
import GeoSuggest from 'react-geosuggest'
import Button from 'antd/lib/button'
import Switch from 'antd/lib/switch'
import tv4 from 'tv4'

const { Option } = Select

const schema = {
  required: [
    'id_type',
    'identifier',
    'result',
    'supportScore',
    'volunteer',
    'issue',
    'deceased',
    'language'
  ],
  type: 'object',
  properties: {
    result: {
      type: 'string',
      enum: ['answered', 'no_answer', 'refused', 'bad_info']
    },
    supportScore: 'number',
    volunteer: 'boolean',
    id_type: 'string',
    identifier: 'string',
    phone: 'string',
    issue: 'string',
    deceased: 'boolean',
    language: {
      type: 'string',
      enum: ['en', 'es']
    }
  }
}

const resultLabels = {
  answered: 'Answered',
  no_answer: 'No Answer',
  refused: 'Refused',
  bad_info: 'Bad Information',
  deceased: 'Deceased',
  language: 'Language – No English'
}

const validate = entry => tv4.validate(entry, schema)

export default class Row extends Component {
  state = {
    id_type: undefined,
    identifier: undefined,
    result: undefined,
    supportScore: undefined,
    volunteer: undefined,
    issue: undefined,
    address: undefined,
    status: 'Go',
  }

  mutate = attr => elOrVal => {
    this.setState({
      status: 'Go',
      [attr]: elOrVal.target === undefined ? elOrVal : elOrVal.target.value
    })
  }

  enterSubmit = ev => ev.keyCode == 13 && this.submit()
  submit = () => {
    const {
      id_type,
      identifier,
      result,
      supportScore,
      volunteer,
      issue,
      address
    } = this.state

    let deceased = false
    let language = 'en'

    let normalizedResult
    if (result == 'deceased') {
      normalizedResult = 'bad_info'
      deceased = true
    } else if (result == 'language') {
      normalizedResult = 'answered'
      language = 'es'
    } else {
      normalizedResult = result
    }

    const payload = {
      id_type,
      identifier,
      supportScore,
      volunteer,
      issue,
      result: normalizedResult,
      deceased,
      language,
      address,
      campaign: this.props.campaign,
      contactMethod: this.props.contactMethod
    }

    const errors = validate(payload)

    this.props.channel.push('entry', {
      n: this.props.counter,
      entry: payload
    })

    this.props.channel.on('update', ({ n, message }) => {
      if (n == this.props.counter) {
        this.setState({ status: message })
      }
    })

    this.props.channel.on('done', ({ n }) => {
      if (n == this.props.counter) {
        this.setState({ status: 'Done' })
      }
    })

    this.props.addRow()
  }

  render() {
    const {
      id_type,
      identifier,
      result,
      supportScore,
      volunteer,
      issue,
      status
    } = this.state

    return (
      <div className="row" onKeyPress={this.enterSubmit}>
        <div className="field">
          <label>Identifier</label>

          <Input
            addonBefore={
              <Select
                value={id_type}
                style={{ width: 70 }}
                onSelect={this.mutate('id_type')}
              >
                <Option value="id"> NationBuilder </Option>
                <Option value="email"> Email </Option>
                <Option value="new"> New </Option>
              </Select>
            }
            value={identifier}
            disabled={id_type == 'new'}
            onChange={this.mutate('identifier')}
          />
        </div>

        <div className="field">
          <label> Result </label>
          <Select name="result" value={result} onChange={this.mutate('result')}>
            {schema.properties.result.enum
              .concat(['deceased', 'language'])
              .map(opt =>
                <Option value={opt} key={opt}>
                  {resultLabels[opt]}
                </Option>
              )}
          </Select>
        </div>

        <div className="field">
          <label> Support Score </label>
          <Select name="supportScore" onChange={this.mutate('supportScore')}>
            <Option value="1">1</Option>
            <Option value="2">2</Option>
            <Option value="3">3</Option>
            <Option value="4">4</Option>
            <Option value="5">5</Option>
          </Select>
        </div>

        <div className="field">
          <label> Volunteer </label>{' '}
          <Switch
            style={{ width: 50 }}
            name="volunteer"
            onChange={this.mutate('volunteer')}
          />
        </div>

        <div className="field">
          <label> Primary Issue </label>
          <Input name="issue" onChange={this.mutate('issue')} />
        </div>

        <div className="field">
          <label> Address </label>
          <GeoSuggest onSuggestSelect={this.mutate('address')}  />
        </div>

        <div className="field">
          <label> Phone </label>
          <Input name="phone" />
        </div>

        <Button
          style={{ marginTop: 15, marginLeft: 15 }}
          type="primary"
          disabled={status == 'Done'}
          onClick={this.submit}
          loading={status != 'Go' && status != 'Done'}
        >
          {status}
        </Button>
      </div>
    )
  }
}
