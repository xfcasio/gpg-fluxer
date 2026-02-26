<p align="center">
    <h1 align="center"> 🔐 gpg-fluxer </h1>
</p>

<p align="center">
    <h4 align="center">
      <samp>Little script that automates sending/decrypting gpg encrypted messages over Fluxer.</samp>
    </h4>
</p>

<br>

> [!important]
> Make sure to put your fluxer token in the `TOKEN` variable in the shell script

> [!tip]
> To get your token, press Ctrl+Shift+I in the app, then:
> `application tab` > `Storage` > `Local Storage` > `https://web.fluxer.app` > scroll to the bottom, there should be
> a key called `token`, its value is the token which starts with `flx_`.

<br>

---

```
usage:

   Encrypt:  gpg-fluxer.sh <TO_EMAIL_GPG> <FLUXER_CHANNEL_ID>

              * Send a GPG encrypted message on the specified fluxer channel using the specified account token
                to the specified recipient (by their email which is connected to their key which you're
                assumed to have imported).


   Decrypt:  gpg-fluxer.sh -d

              * Decrypt GPG encrypted message from your clipboard.



   * Assumes the user has set up a gpg key
   * Assumes the recipient's key is imported
```
