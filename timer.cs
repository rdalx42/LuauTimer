using System.Collections;
using TMPro;
using UnityEngine;

public class timerscript : MonoBehaviour
{
    
    public TextMeshProUGUI label;
    public bool is_running = false;

    private float current_time = 0f;

    private void Start()
    {
        StartCoroutine(start_timer());
    }

    public IEnumerator start_timer()
    {
        
        current_time = 0f;
        is_running = true;
        while (is_running)
        {
            yield return new WaitForSeconds(0.01f);
            current_time += 0.01f;

            int minutes = Mathf.FloorToInt(current_time / 60f);
            int seconds = Mathf.FloorToInt(current_time % 60f);
            int milliseconds = Mathf.FloorToInt((current_time * 1000f) % 1000f);

            label.text = string.Format("{0:00}:{1:00}.{2:000}", minutes, seconds, milliseconds);
        }
    }

    public void stop_timer()
    {
        current_time = 0f;
        is_running = false;
        label.text = "00:00.000";
    }
}
