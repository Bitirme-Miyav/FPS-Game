using System;
using UnityEngine;
using UnityEngine.InputSystem;

public class RiffleWeapon : MonoBehaviour
{
    [SerializeField] private Transform _muzzleTransform;
    [SerializeField] private ParticleSystem _muzzleEffect;
    [SerializeField] private Bullet _bulletPrefab;

    [SerializeField] private float _bulletSpeed;
    [SerializeField] private float _fireDuration;
    private float _fireTimer;

    private bool _isActive;

    public void Enable()
    {
        Cursor.visible = false;
        _isActive = true;
    }

    public void Disable()
    {
        Cursor.visible = true;
        _isActive = false;
    }

    private void Update()
    {
        if(!_isActive)
            return;

        var isFired = InputManager.Instance.PlayerFired();
        if (isFired)
        {
            FireProgress();
        }
    }

    private void FireProgress()
    {
        Fire();
    }

    private void Fire()
    {
        var bullet = Instantiate(_bulletPrefab);
        bullet.transform.SetParent(_muzzleTransform);
        bullet.transform.localPosition = Vector3.zero;
        bullet.transform.localEulerAngles = Vector3.zero;
        
        bullet.Initialize();
        bullet.Fire(_bulletSpeed);
        
        _muzzleEffect.Play(true);
    }
}