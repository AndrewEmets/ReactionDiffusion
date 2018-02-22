using System;
using UnityEngine;
using UnityEngine.UI;

public class ReactionController : MonoBehaviour
{
    [SerializeField] private ReactionDiffustionUpdater updater;
    [SerializeField] private Text indexText, prefsText;

    [SerializeField] private Button buttonPrev, buttonNext, buttonInitTex;

    private void Awake()
    {
        updater.CurrentPrefsChanged += Updater_CurrentPrefsChanged;
    }

    private void Start()
    {
        buttonNext.onClick.AddListener(OnNextClick);
        buttonPrev.onClick.AddListener(OnPrevClick);
        buttonInitTex.onClick.AddListener(InitTexClick);
    }

    private void InitTexClick()
    {
        updater.BlitInitTexture();
    }

    private void OnNextClick()
    {
        updater.CurrentPrefs++;
    }

    private void OnPrevClick()
    {
        updater.CurrentPrefs--;
    }

    private void Updater_CurrentPrefsChanged(int index, ReactionDiffustionUpdater.UpdatePrefs prefs)
    {
        indexText.text = string.Format("{0}/{1}", index + 1, updater.PrefsCount);
        prefsText.text = string.Format("Feed rate    : {0}\nKill rate    : {1}\nDiffusion (A): {2}\nDiffusion (B): {3}", prefs.feed, prefs.kill, prefs.da, prefs.db);
    }
}
