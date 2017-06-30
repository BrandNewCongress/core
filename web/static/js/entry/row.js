import React, { Component } from 'react'
import tv4 from 'tv4'

const print = s => {
  console.log(s)
  return s
}

const schema = {
  required: [
    'emailOrPhone',
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
    emailOrPhone: {
      type: 'string',
      enum: ['email', 'phone']
    },
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
    emailOrPhone: undefined,
    identifier: undefined,
    result: undefined,
    supportScore: undefined,
    volunteer: undefined,
    issue: undefined,
    status: 'Press Enter'
  }

  mutate = attr => ev => this.setState({ [attr]: ev.target.value })
  determineIdType = ev =>
    this.setState({
      emailOrPhone: print(this.state.identifier).match('@')
        ? 'email'
        : this.state.identifier.match(/[a-zA-Z]/) ? false : 'phone'
    })

  enterSubmit = ev => ev.keyCode == 13 && this.submit()
  submit = () => {
    const {
      emailOrPhone,
      identifier,
      result,
      supportScore,
      volunteer,
      issue
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
      normalizedResult = 'result'
    }

    const payload = {
      emailOrPhone,
      identifier,
      supportScore,
      volunteer,
      issue,
      result: normalizedResult,
      deceased,
      language,
      campaign: this.props.campaign,
      contactMethod: this.props.contactMethod
    }

    const errors = validate(payload)
    console.log(errors)

    console.log(payload)

    // TODO - do submit
    this.props.addRow()
  }

  render() {
    const {
      emailOrPhone,
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
          <label for="identifier">
            {emailOrPhone === undefined
              ? 'Email or Phone'
              : emailOrPhone === false
                ? 'Invalid Identifier – Neither Email nor Phone'
                : emailOrPhone === 'email' ? 'Email' : 'Phone'}
          </label>
          <input
            name="identifier"
            type="text"
            value={identifier}
            onChange={this.mutate('identifier')}
            onBlur={this.determineIdType}
          />
        </div>

        <div className="field">
          <label for="result"> Result </label>
          <select name="result" value={result} onChange={this.mutate('result')}>
            {schema.properties.result.enum
              .concat(['deceased', 'language'])
              .map(opt => <option value={opt}> {resultLabels[opt]} </option>)}
          </select>
        </div>

        <div className="field">
          <label for="supportScore"> Support Score </label>
          <input
            name="supportScore"
            type="number"
            onChange={this.mutate('supportScore')}
          />
        </div>

        <div className="field">
          <label for="volunteer"> Volunteer </label>{' '}
          <span style={{ fontSize: 'small' }}> (toggle with spacebar) </span>
          <input
            name="volunteer"
            type="checkbox"
            onChange={this.mutate('volunteer')}
          />
        </div>

        <div className="field">
          <label for="issue"> Primary Issue </label>
          <input name="issue" onChange={this.mutate('issue')} />
        </div>

        <div
          style={{
            display: 'flex',
            justifyContent: 'center',
            flexDirection: 'column',
            marginLeft: '20px'
          }}
        >
          {status}
        </div>
      </div>
    )
  }
}
