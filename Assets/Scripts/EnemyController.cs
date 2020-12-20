using System;
using DefaultNamespace;
using DG.Tweening;
using RootMotion.Dynamics;
using UnityEngine;

public class EnemyController : MonoBehaviour
{
    public bool IsDead;
    
    [SerializeField] private PuppetMaster _puppetMaster;
    [SerializeField] private Animator _animator;

    [SerializeField] private MovementPath _movementPath;

    [SerializeField] private float _movementSpeed;
    private Vector3[] _pathPoints;
    private int _pathIndex;

    private bool _reversePath;
    
    private void Start()
    {
        _movementPath.transform.SetParent(null);
        _pathPoints = _movementPath.GetPoints();
        _pathIndex = 0;
    }

    private void Update()
    {
        if(IsDead)
            return;
        
        Movement();
    }

    private void Movement()
    {
        var currentPoint = _pathPoints[_pathIndex];

        var distance = Vector3.Distance(transform.position, currentPoint);
        if (distance <= .1f)
        {
            if (!_reversePath)
                _pathIndex++;
            else
                _pathIndex--;

            if (_pathIndex >= _pathPoints.Length && !_reversePath)
            {
                _reversePath = true;
                _pathIndex = _pathPoints.Length - 1;
            }
            else if (_pathIndex < 0 && _reversePath)
            {
                _pathIndex = 0;
                _reversePath = false;
            }
        }

        transform.position = Vector3.MoveTowards(transform.position, currentPoint, _movementSpeed * Time.deltaTime);

        var lookDirection = currentPoint - transform.position;
        lookDirection.y = 0;

        var targetRotation = Quaternion.LookRotation(lookDirection);
        transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, 5 * Time.deltaTime);
    }

    public void Dead()
    {
        _puppetMaster.state = PuppetMaster.State.Dead;
        _animator.SetTrigger("dead");

        IsDead = true;
        
        EnemyManager.OnEnemyDead?.Invoke();
    }
}