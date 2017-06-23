const days = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday'
]

const months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
]

const getLocalHours = (date, offset) => {
  let base = date.getUTCHours() + offset
  if (base < 0) return 24 + base
  return base
}

export default (date, offset) => ({
  dayOfWeek: days[date.getDay()],
  month: months[date.getMonth()],
  dayOfMonth: date.getDate(),
  humanTime: `${getLocalHours(date, offset) % 12 || 12}${date.getMinutes() ? ':' + date.getMinutes() : ''} ${getLocalHours(date, offset) >= 12 ? 'PM' : 'AM'}`
})
