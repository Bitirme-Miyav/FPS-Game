using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace DefaultNamespace
{
    public class EnemyManager : MonoBehaviour
    {
        private List<EnemyController> _allEnemies;
        [SerializeField] private GameObject _victoryText;

        public static Action OnEnemyDead;

        private void Start()
        {
            _allEnemies = FindObjectsOfType<EnemyController>().ToList();

            OnEnemyDead += () =>
            {
                var aliveEnemies = _allEnemies.Count(x => !x.IsDead);
                if (aliveEnemies == 0)
                {
                    Debug.Log("Level Completed!");
                    _victoryText.SetActive(true);
                    // TODO: Integrate Level Complete UI
                }
            };
        }
    }
}