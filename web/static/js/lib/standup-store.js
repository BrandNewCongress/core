import socket from '../socket'

const channel = socket.channel('standup')

channel
  .join()
  .receive('ok', msg => {
    console.log(`Connected`)
  })
  .receive('error', msg => {
    console.log(`Could not connect with ${JSON.stringify(msg)}`)
  })

const videos = {
  for: district =>
    new Promise((resolve, reject) => {
      channel.push('videos-for', { district })
      channel.on(`videos-for-${district}`, ({ videos }) => {
        channel.off(`videos-for-${district}`)
        resolve(videos)
      })
    }),

  recent: () =>
    new Promise((resolve, reject) => {
      channel.push('recent-videos')
      channel.on('recent-videos', ({ videos }) => {
        channel.off('recent-videos')
        resolve(videos)
      })
    })
}

const create = data =>
  new Promise((resolve, reject) => {
    channel.push('create-video', data)
    channel.on('video-created', () => {
      channel.off('video-created')
      resolve(true)
    })
  })

const reps = {
  get: () =>
    new Promise((resolve, reject) => {
      channel.push('congress', {})
      channel.on('congress', data => {
        channel.off('congress')
        resolve(data)
      })
    })
}

export default { videos, reps }
